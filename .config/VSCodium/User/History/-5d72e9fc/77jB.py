import os
import asyncio
import edge_tts
import argparse
import concurrent.futures
import time
import subprocess
import re
import signal
import sys

def normalize_vietnamese_text(text):
    """Simple Vietnamese text normalization without vinorm for multi-threading support"""
    # Basic punctuation fixes
    text = re.sub(r'\.{2,}', '.', text)  # Replace multiple dots with single dot
    text = re.sub(r'!\.', '!', text)     # Fix !.
    text = re.sub(r'\?\.', '?', text)    # Fix ?.
    text = re.sub(r' \.', '.', text)     # Fix space before dot
    text = re.sub(r' ,', ',', text)      # Fix space before comma
    text = text.replace('"', '').replace("'", '')  # Remove quotes
    
    # Common abbreviations and terms
    replacements = {
        "AI": "Ây Ai",
        "exp": "kinh nghiệm",
        "Exp": "kinh nghiệm",
        "A.I": "Ây Ai",
        "Mr.": "Mister",
        "Mrs.": "Misses",
        "Ms.": "Miss",
        "Dr.": "Doctor",
        "Prof.": "Professor",
        "St.": "Saint",
        "Co.": "Company",
        "Inc.": "Incorporated",
        "Ltd.": "Limited",
        "etc.": "etcetera",
        "vs.": "versus",
        "i.e.": "that is",
        "e.g.": "for example",
        "a.m.": "am",
        "p.m.": "pm",
        "AD": "Anno Domini",
        "BC": "Before Christ",
        "CEO": "C E O",
        "CFO": "C F O",
        "CTO": "C T O",
        "USA": "U S A",
        "UK": "U K",
        "UN": "U N",
        "IoT": "I O T",
        "URL": "U R L",
        "HTTP": "H T T P",
        "HTTPS": "H T T P S",
        "HTML": "H T M L",
        "CSS": "C S S",
        "JS": "JavaScript",
        "API": "A P I",
        "CPU": "C P U",
        "GPU": "G P U",
        "RAM": "R A M",
        "ROM": "R O M",
        "OS": "O S",
        "PC": "P C",
        "TV": "T V",
        "DVD": "D V D",
        "CD": "C D",
        "USB": "U S B",
        "WiFi": "Wi Fi",
        "PhD": "P H D",
        "tp.": "thành phố",
        "TP.": "Thành phố",
        "q.": "quận",
        "Q.": "Quận",
        "ph.": "phường",
        "Ph.": "Phường",
        "đ.": "đường",
        "Đ.": "Đường",
        "+": "cộng ",
        "/": " trên ",
    }
    
    for old, new in replacements.items():
        text = text.replace(old, new)
    
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

def process_file(file_path, base_dir, output_dir, progress_file, processing_files):
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
    
    # Add to processing files set
    processing_files.add(file_path)
    
    try:
        # Read and normalize text
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()
        normalized_text = normalize_vietnamese_text(text)
        
        # Convert to audio using temporary file
        temp_output_path = output_path + '.tmp'
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        success = loop.run_until_complete(convert_to_audio(normalized_text, temp_output_path))
        loop.close()
        
        if success:
            # Rename temporary file to final location only if successful
            os.rename(temp_output_path, output_path)
            
            # Update progress file only after successful conversion
            with open(progress_file, 'a') as f:
                f.write(f"{file_path}\n")
            print(f"Successfully processed: {os.path.basename(file_path)}")
        else:
            # Clean up temporary file if conversion failed
            if os.path.exists(temp_output_path):
                os.remove(temp_output_path)
            print(f"Failed to process: {os.path.basename(file_path)}")
        
        return success
    finally:
        # Remove from processing files set
        processing_files.discard(file_path)

def extract_chapter_info(file_path):
    """Extract chapter number and part number for proper sorting"""
    basename = os.path.basename(file_path)
    
    # Extract main chapter number
    chapter_match = re.match(r'^(\d+)', basename)
    if not chapter_match:
        return (float('inf'), 0)  # No chapter found, put at the end
    
    chapter_num = int(chapter_match.group(1))
    
    # Check for part number (e.g., "299-2")
    part_match = re.search(r'Chương \d+-(\d+)', basename)
    if part_match:
        part_num = int(part_match.group(1))
    else:
        part_num = 0
    
    return (chapter_num, part_num)

def concatenate_audio_files(output_dir, final_output):
    # Create list of all audio files
    audio_files = []
    for root, _, files in os.walk(output_dir):
        for file in files:
            if file.endswith('.mp3') and not file.startswith('combined_'):
                audio_files.append(os.path.join(root, file))
    
    # Sort by chapter number and part number for correct order
    audio_files.sort(key=extract_chapter_info)
    
    # Create temporary list file for ffmpeg
    list_file = os.path.join(output_dir, 'concat_list.txt')
    with open(list_file, 'w') as f:
        for audio_file in audio_files:
            # Use relative path from output_dir to the audio file
            rel_path = os.path.relpath(audio_file, output_dir)
            f.write(f"file '{rel_path}'\n")
    
    # Change to output_dir to ensure relative paths work correctly
    original_dir = os.getcwd()
    os.chdir(output_dir)
    
    try:
        # Use ffmpeg to concatenate
        cmd = [
            'ffmpeg', '-f', 'concat', '-safe', '0', 
            '-i', 'concat_list.txt', '-c', 'copy', 
            os.path.basename(final_output)
        ]
        subprocess.run(cmd, check=True)
        
        # Move the final output file to the correct location if needed
        if os.path.dirname(final_output):
            os.rename(os.path.basename(final_output), final_output)
        
        print(f"Successfully created combined audio: {final_output}")
    finally:
        # Change back to original directory
        os.chdir(original_dir)
        
        # Clean up temporary file
        # if os.path.exists(list_file):
        #     os.remove(list_file)

def signal_handler(sig, frame, processing_files, output_dir, args):
    print("\nInterrupt received. Cleaning up...")
    # Clean up any temporary files that might be left from interrupted processing
    for file_path in list(processing_files):
        relative_path = os.path.relpath(file_path, args.base_dir)
        temp_output_path = os.path.join(output_dir, relative_path.replace('.txt', '.mp3.tmp'))
        if os.path.exists(temp_output_path):
            os.remove(temp_output_path)
            print(f"Removed temporary file: {temp_output_path}")
    sys.exit(0)

def main():
    parser = argparse.ArgumentParser(description='Convert novel chapters to audio files.')
    parser.add_argument('base_dir', help='Base directory containing novel chapters')
    parser.add_argument('--output_dir', default='audio', help='Output directory for audio files')
    parser.add_argument('--final_output', default='combined_novel.mp3', help='Final combined audio file')
    parser.add_argument('--threads', type=int, default=5, help='Number of threads for parallel processing')
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
    
    # Clean up any temporary files from previous runs
    for root, _, files in os.walk(args.output_dir):
        for file in files:
            if file.endswith('.tmp'):
                os.remove(os.path.join(root, file))
    
    # Collect all text files
    text_files = []
    for root, _, files in os.walk(args.base_dir):
        for file in files:
            if file.endswith('.txt'):
                file_path = os.path.join(root, file)
                # Skip if already processed
                if file_path not in processed_files:
                    text_files.append(file_path)
    
    # Sort files by chapter number and part number
    text_files.sort(key=extract_chapter_info)
    
    print(f"Found {len(text_files)} text files to process")
    
    # Set up signal handler for clean exit
    processing_files = set()
    signal.signal(signal.SIGINT, lambda sig, frame: signal_handler(sig, frame, processing_files, args.output_dir, args))
    
    # Process files with thread pool
    all_successful = True
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = []
        for file_path in text_files:
            futures.append(executor.submit(
                process_file, file_path, args.base_dir, args.output_dir, progress_file, processing_files
            ))
        
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
# 1. Basic usage with default settings (5 threads):
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