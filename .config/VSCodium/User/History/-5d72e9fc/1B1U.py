import os
import asyncio
import edge_tts
import argparse
import concurrent.futures
import time
import subprocess
import re
import threading

# Configuration
MAX_CONCURRENT_TTS = 3      # Max concurrent TTS requests
BATCH_SIZE = 10            # Process files in batches to reduce memory usage

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
        "+": "công ",
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

def process_file(file_path, base_dir, output_dir, progress_file, semaphore):
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
    with semaphore:
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
            if file.endswith('.mp3') and not file.startswith('combined_'):
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
    
    # Create semaphore to limit concurrent TTS requests
    semaphore = threading.Semaphore(MAX_CONCURRENT_TTS)
    
    # Process files in batches
    all_successful = True
    for i in range(0, len(text_files), BATCH