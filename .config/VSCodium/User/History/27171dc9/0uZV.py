import argparse
import os
import re
import time
import torch
import torchaudio
from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts
from vinorm import TTSnorm

def normalize_vietnamese_text(text):
    text = (
        TTSnorm(text, unknown=False, lower=False, rule=True)
        .replace("..", ".")
        .replace("!.", "!")
        .replace("?.", "?")
        .replace(" .", ".")
        .replace(" ,", ",")
        .replace('"', "")
        .replace("'", "")
        .replace("AI", "Ây Ai")
        .replace("A.I", "Ây Ai")
    )
    return text

def calculate_keep_len(text, lang):
    """Simple hack for short sentences"""
    if lang in ["ja", "zh-cn"]:
        return -1

    word_count = len(text.split())
    num_punct = text.count(".") + text.count("!") + text.count("?") + text.count(",")

    if word_count < 5:
        return 15000 * word_count + 2000 * num_punct
    elif word_count < 10:
        return 13000 * word_count + 2000 * num_punct
    return -1

def main():
    parser = argparse.ArgumentParser(description="Vietnamese TTS using XTTS")
    parser.add_argument("--text", type=str, required=True, help="Text to synthesize")
    parser.add_argument("--ref_voice", type=str, required=True, help="Reference audio file path")
    parser.add_argument("--output", type=str, default="output.wav", help="Output audio file path")
    parser.add_argument("--language", type=str, default="vi", help="Language code")
    parser.add_argument("--normalize", action="store_true", help="Normalize Vietnamese text")
    
    args = parser.parse_args()
    
    # Download model if not exists
    
    checkpoint_dir = "model/"
    repo_id = "capleaf/viXTTS"
    
    os.makedirs(checkpoint_dir, exist_ok=True)
    
    required_files = ["model.pth", "config.json", "vocab.json", "speakers_xtts.pth"]
    files_in_dir = os.listdir(checkpoint_dir)
    if not all(file in files_in_dir for file in required_files):
        print("Downloading if not downloaded viXTTS")
        from huggingface_hub import snapshot_download, hf_hub_download
        snapshot_download(
            repo_id=repo_id,
            repo_type="model",
            local_dir=checkpoint_dir,
        )
        hf_hub_download(
            repo_id="coqui/XTTS-v2",
            filename="speakers_xtts.pth",
            local_dir=checkpoint_dir,
        )
    
    # Load model
    xtts_config = os.path.join(checkpoint_dir, "config.json")
    config = XttsConfig()
    config.load_json(xtts_config)
    model = Xtts.init_from_config(config)
    model.load_checkpoint(
        config, checkpoint_dir=checkpoint_dir, use_deepspeed=False
    )
    if torch.cuda.is_available():
        model.cuda()
    
    # Check language support
    supported_languages = config.languages
    if args.language not in supported_languages:
        if args.language == "vi" and "vi" not in supported_languages:
            supported_languages.append("vi")
        else:
            raise ValueError(f"Language {args.language} not supported. Supported: {supported_languages}")
    
    # Validate inputs
    if len(args.text) < 2:
        raise ValueError("Text prompt is too short")
    
    # Process text
    prompt = re.sub("([^\x00-\x7F]|\w)(\.|\。|\?)", r"\1 \2\2", args.text)
    
    if args.normalize and args.language == "vi":
        prompt = normalize_vietnamese_text(prompt)
    
    print("Generating audio...")
    t0 = time.time()
    
    try:
        # Get conditioning latents
        gpt_cond_latent, speaker_embedding = model.get_conditioning_latents(
            audio_path=args.ref_voice,
            gpt_cond_len=30,
            gpt_cond_chunk_len=4,
            max_ref_length=60,
        )
        
        # Generate audio
        out = model.inference(
            prompt,
            args.language,
            gpt_cond_latent,
            speaker_embedding,
            repetition_penalty=5.0,
            temperature=0.75,
            enable_text_splitting=True,
        )
        
        # Process output
        inference_time = time.time() - t0
        print(f"Time to generate audio: {round(inference_time*1000)} milliseconds")
        
        real_time_factor = (time.time() - t0) / out["wav"].shape[-1] * 24000
        print(f"Real-time factor (RTF): {real_time_factor:.2f}")
        
        # Apply length adjustment for short sentences
        keep_len = calculate_keep_len(prompt, args.language)
        if keep_len > 0:
            out["wav"] = out["wav"][:keep_len]
        
        # Save audio
        torchaudio.save(args.output, torch.tensor(out["wav"]).unsqueeze(0), 24000)
        print(f"Audio saved to {args.output}")
        
    except Exception as e:
        print(f"Error during generation: {str(e)}")
        raise

if __name__ == "__main__":
    # Download for mecab
    # os.system("python -m unidic download")
    main()