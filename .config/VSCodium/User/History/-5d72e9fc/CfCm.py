import os
import asyncio
import edge_tts
from vinorm import TTSnorm
import argparse
import concurrent.futures
import time
import subprocess
import re

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

def process_file(file_path, base_dir, output_dir, progress_file):
    # Create output filename preserving original structure
    relative_path = os.path.relpath(file_path, base_dir)
    output_path = os.path.join(output_dir, relative_path.replace('.txt', '.mp3'))
    
    # Create output directory if needed
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Skip if already processed
    if os.path.exists(output_path):
        print(f"Skipping already processed: {os.path.basename(file_path)}")
        return True
    
    # Extract chapter number for progress display
    chapter_num = re.search(r'^(\d+)', os.path.basename(file_path))
    chapter_display = chapter_num.group(1) if chapter_num else "Unknown"
    
    print(f"Processing chapter {chapter_display}: {os.path.basename(file_path)}")
    
    # Read and normalize text
    with open(file_path, 'r', encoding='utf-8') as file:
        text = file.read()
    normalized_text = normalize_vietnamese_text(text)
    
    # Convert to audio
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    success = loop.run_until_complete(convert_to_audio(normalized_text, output_path))
    loop.close()
    
    if success:
        # Update progress file
        with open(progress_file, 'a') as f:
            f.write(f"{file_path}\n")
        print(f"Successfully processed: {os.path.basename(file_path)}")
    else:
        print(f"Failed to process: {os.path.basename(file_path)}")
    
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
    
    # Progress tracking file
    progress_file = os.path.join(args.output_dir, 'progress.txt')
    
    # Load already processed files
    processed_files = set()
    if os.path.exists(progress_file):
        with open(progress_file, 'r') as f:
            processed_files = set(line.strip() for line in f.readlines())
    
    # Collect all text files
    text_files = []
    for root, _, files in os.walk(args.base_dir):
        for file in files:
            if file.endswith('.txt'):
                file_path = os.path.join(root, file)
                # Skip if already processed
                if file_path not in processed_files:
                    text_files.append(file_path)
    
    # Sort files by chapter number (extract numeric prefix)
    def extract_chapter_num(file_path):
        basename = os.path.basename(file_path)
        match = re.match(r'^(\d+)', basename)
        return int(match.group(1)) if match else float('inf')
    
    text_files.sort(key=extract_chapter_num)
    
    print(f"Found {len(text_files)} text files to process")
    
    # Process files with thread pool
    all_successful = True
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = []
        for file_path in text_files:
            futures.append(executor.submit(process_file, file_path, args.base_dir, args.output_dir, progress_file))
        
        for i, future in enumerate(concurrent.futures.as_completed(futures)):
            result = future.result()
            print(f"Progress: {i+1}/{len(text_files)} files processed")
            if not result:
                all_successful = False
                print(f"Failed to process file: {text_files[i]}")
    
    # Only concatenate if all files were processed successfully
    if all_successful:
        print("All files processed successfully. Concatenating audio files...")
        concatenate_audio_files(args.output_dir, args.final_output)
        print("Processing complete!")
    else:
        print("Some files failed to process. Skipping concatenation.")
        print("You can run the script again to retry failed files.")

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
#
# 5. Resume interrupted processing:
#    python novel_to_audio.py novel_chapters  # Script will automatically skip already processed files