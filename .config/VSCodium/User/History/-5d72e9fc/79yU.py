import os
import asyncio
import edge_tts
from vinorm import TTSnorm
import argparse
import concurrent.futures
import time
import subprocess
import shutil

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
        .replace("exp", "kinh nghiệm")
        .replace("Exp", "kinh nghiệm")
        .replace("A.I", "Ây Ai")
        .replace("+", "cộng ")
        .replace("/", " trên ")
        # Add more normalization rules below
        .replace("Mr.", "Mister")
        .replace("Mrs.", "Misses")
        .replace("Ms.", "Miss")
        .replace("Dr.", "Doctor")
        .replace("Prof.", "Professor")
        .replace("St.", "Saint")
        .replace("Co.", "Company")
        .replace("Inc.", "Incorporated")
        .replace("Ltd.", "Limited")
        .replace("etc.", "etcetera")
        .replace("vs.", "versus")
        .replace("i.e.", "that is")
        .replace("e.g.", "for example")
        .replace("a.m.", "am")
        .replace("p.m.", "pm")
        .replace("AD", "Anno Domini")
        .replace("BC", "Before Christ")
        .replace("CEO", "C E O")
        .replace("CFO", "C F O")
        .replace("CTO", "C T O")
        .replace("USA", "U S A")
        .replace("UK", "U K")
        .replace("UN", "U N")
        .replace("IoT", "I O T")
        .replace("URL", "U R L")
        .replace("HTTP", "H T T P")
        .replace("HTTPS", "H T T P S")
        .replace("HTML", "H T M L")
        .replace("CSS", "C S S")
        .replace("JS", "JavaScript")
        .replace("API", "A P I")
        .replace("CPU", "C P U")
        .replace("GPU", "G P U")
        .replace("RAM", "R A M")
        .replace("ROM", "R O M")
        .replace("OS", "O S")
        .replace("PC", "P C")
        .replace("TV", "T V")
        .replace("DVD", "D V D")
        .replace("CD", "C D")
        .replace("USB", "U S B")
        .replace("WiFi", "Wi Fi")
        .replace("PhD", "P H D")
        .replace("tp.", "thành phố")
        .replace("TP.", "Thành phố")
        .replace("q.", "quận")
        .replace("Q.", "Quận")
        .replace("ph.", "phường")
        .replace("Ph.", "Phường")
        .replace("đ.", "đường")
        .replace("Đ.", "Đường")
    )
    return text

async def convert_to_audio(text, output_path, max_retries=5):
    for attempt in range(max_retries):
        try:
            communicate = edge_tts.Communicate(text, "vi-VN-NamMinhNeural")
            await communicate.save(output_path)
            return True
        except Exception as e:
            if attempt == max_retries - 1:
                print(f"Failed to convert {output_path} after {max_retries} attempts: {e}")
                return False
            print(f"Attempt {attempt+1} failed for {output_path}. Retrying... Error: {e}")
            await asyncio.sleep(2)

def process_file(file_path, output_dir):
    # Create output filename preserving original structure
    relative_path = os.path.relpath(file_path, args.base_dir)
    output_path = os.path.join(output_dir, relative_path.replace('.txt', '.mp3'))
    
    # Create output directory if needed
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Skip if already processed
    if os.path.exists(output_path):
        print(f"Skipping already processed: {output_path}")
        return True
    
    # Read and normalize text
    with open(file_path, 'r', encoding='utf-8') as file:
        text = file.read()
    normalized_text = normalize_vietnamese_text(text)
    
    # Convert to audio
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    success = loop.run_until_complete(convert_to_audio(normalized_text, output_path))
    loop.close()
    
    return success

def concatenate_audio_files(output_dir, final_output):
    # Create list of all audio files in correct order
    audio_files = []
    for root, _, files in os.walk(output_dir):
        for file in sorted(files):
            if file.endswith('.mp3'):
                audio_files.append(os.path.join(root, file))
    
    # Create temporary list file for ffmpeg
    list_file = os.path.join(output_dir, 'concat_list.txt')
    with open(list_file, 'w') as f:
        for audio_file in audio_files:
            f.write(f"file '{audio_file}'\n")
    
    # Use ffmpeg to concatenate
    cmd = [
        'ffmpeg', '-f', 'concat', '-safe', '0', 
        '-i', list_file, '-c', 'copy', final_output
    ]
    subprocess.run(cmd, check=True)
    
    # Clean up temporary file
    os.remove(list_file)
    print(f"Successfully created combined audio: {final_output}")

def main():
    parser = argparse.ArgumentParser(description='Convert novel chapters to audio files.')
    parser.add_argument('base_dir', help='Base directory containing novel chapters')
    parser.add_argument('--output_dir', default='audio', help='Output directory for audio files')
    parser.add_argument('--final_output', default='combined_novel.mp3', help='Final combined audio file')
    parser.add_argument('--threads', type=int, default=3, help='Number of threads for parallel processing')
    args = parser.parse_args()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    # Collect all text files
    text_files = []
    for root, _, files in os.walk(args.base_dir):
        for file in files:
            if file.endswith('.txt'):
                text_files.append(os.path.join(root, file))
    
    print(f"Found {len(text_files)} text files to process")
    
    # Process files with thread pool
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = []
        for file_path in text_files:
            futures.append(executor.submit(process_file, file_path, args.output_dir))
        
        for i, future in enumerate(concurrent.futures.as_completed(futures)):
            result = future.result()
            print(f"Progress: {i+1}/{len(text_files)} files processed")
            if not result:
                print(f"Failed to process file: {text_files[i]}")
    
    # Concatenate all audio files
    concatenate_audio_files(args.output_dir, args.final_output)
    print("Processing complete!")

if __name__ == "__main__":
    main()

# Usage Examples:
# 1. Basic usage with default settings:
#    python novel_to_audio.py novel_chapters
#
# 2. Specify custom output directory and final output file:
#    python novel_to_audio.py novel_chapters --output_dir my_audio --final_output my_novel.mp3
#
# 3. Use more threads for faster processing:
#    python novel_to_audio.py novel_chapters --threads 8
#
# 4. Process novels in different directory:
#    python novel_to_audio.py /path/to/novel_chapters