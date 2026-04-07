import spaces
import os
from huggingface_hub import login
import gradio as gr
from cached_path import cached_path
import tempfile
import numpy as np
from vinorm import TTSnorm
from infer_zipvoice import (
    model,
    tokenizer,
    feature_extractor,
    device,
    generate_sentence,
    vocoder,
)
from utils import preprocess_ref_audio_text, save_spectrogram, chunk_text

# Retrieve token from secrets
hf_token = os.getenv("HUGGINGFACEHUB_API_TOKEN")

# Log in to Hugging Face
if hf_token:
    login(token=hf_token)


def post_process(text):
    text = " " + text + " "
    text = text.replace(" . . ", " . ")
    text = " " + text + " "
    text = text.replace(" .. ", " . ")
    text = " " + text + " "
    text = text.replace(" , , ", " , ")
    text = " " + text + " "
    text = text.replace(" ,, ", " , ")
    text = " " + text + " "
    text = text.replace('"', "")
    return " ".join(text.split())


@spaces.GPU
def infer_tts(
    ref_audio_orig: str, gen_text: str, speed: float = 1.0, request: gr.Request = None
):

    if not ref_audio_orig:
        raise gr.Error("Please upload a sample audio file.")
    if not gen_text.strip():
        raise gr.Error("Please enter the text content to generate voice.")
    if len(gen_text.split()) > 1000:
        raise gr.Error("Please enter text content with less than 1000 words.")

    try:
        gen_texts = chunk_text(gen_text)
        final_wave_total = None
        final_sample_rate = 24000
        ref_audio, ref_text = "", ""
        for i, gen_text in enumerate(gen_texts):
            if i == 0:
                ref_audio, ref_text = preprocess_ref_audio_text(ref_audio_orig, "")
            final_wave = (
                generate_sentence(
                    ref_text.lower(),
                    ref_audio,
                    post_process(TTSnorm(gen_text)).lower(),
                    model=model,
                    vocoder=vocoder,
                    tokenizer=tokenizer,
                    feature_extractor=feature_extractor,
                    device=device,
                    speed=speed,
                )
                .detach()
                .numpy()[0]
            )
            if i == 0:
                final_wave_total = final_wave
            else:
                final_wave_total = np.concatenate(
                    (final_wave_total, final_wave, np.zeros(6000, dtype=int)), axis=0
                )
        with tempfile.NamedTemporaryFile(
            suffix=".png", delete=False
        ) as tmp_spectrogram:
            spectrogram_path = tmp_spectrogram.name
            save_spectrogram(final_wave_total, spectrogram_path)

        return (final_sample_rate, final_wave_total), spectrogram_path
    except Exception as e:
        raise gr.Error(f"Error generating voice: {e}")


# Gradio UI
with gr.Blocks(theme=gr.themes.Soft()) as demo:
    gr.Markdown(
        """
    # 🎤 ZipVoice: Zero-shot Vietnamese Text-to-Speech Synthesis using Flow Matching with only 123M parameters.
    # The model was trained with approximately 2500 hours of data on a RTX 3090 GPU. 
    Enter text and upload a sample voice to generate natural speech.
    """
    )

    with gr.Row():
        ref_audio = gr.Audio(label="🔊 Sample Voice", type="filepath")
        gen_text = gr.Textbox(
            label="📝 Text", placeholder="Enter the text to generate voice...", lines=3
        )

    speed = gr.Slider(0.3, 2.0, value=1.0, step=0.1, label="⚡ Speed")
    btn_synthesize = gr.Button("🔥 Generate Voice")

    with gr.Row():
        output_audio = gr.Audio(label="🎧 Generated Audio", type="numpy")
        output_spectrogram = gr.Image(label="📊 Spectrogram")

    model_limitations = gr.Textbox(
        value="""1. This model may not perform well with numerical characters, dates, special characters, etc.
2. The rhythm of some generated audios may be inconsistent or choppy.
3. Default, reference audio text uses the pho-whisper-medium model, which may not always accurately recognize Vietnamese, resulting in poor voice synthesis quality.
4. Inference with overly long paragraphs may produce poor results.
5. This demo uses a for loop to generate audio for each sentence sequentially in long paragraphs, so the speed may be slow""",
        label="❗ Model Limitations",
        lines=5,
        interactive=False,
    )

    btn_synthesize.click(
        infer_tts,
        inputs=[ref_audio, gen_text, speed],
        outputs=[output_audio, output_spectrogram],
    )

# Run Gradio with share=True to get a gradio.live link
demo.queue().launch()
