import os
import asyncio
import edge_tts
from vinorm import TTSnorm
import argparse
import concurrent.futures
import time

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

def process_folder(folder_path, output_filename):
    text_parts = []
    for filename in sorted(os.listdir(folder_path)):
        if filename.endswith('.txt'):
            with open(os.path.join(folder_path, filename), 'r', encoding='utf-8') as file:
                text_parts.append(file.read())
    combined_text = "\n\n".join(text_parts)
    normalized_text = normalize_vietnamese_text(combined_text)
    
    output_path = os.path.join(folder_path, output_filename)
    
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    success = loop.run_until_complete(convert_to_audio(normalized_text, output_path))
    loop.close()
    
    return success

def main():
    parser = argparse.ArgumentParser(description='Convert novel chapters to audio files.')
    parser.add_argument('base_dir', help='Base directory containing novel chapters')
    parser.add_argument('--threads', type=int, default=3, help='Number of threads for parallel processing')
    args = parser.parse_args()
    
    base_dir = args.base_dir
    max_threads = args.threads
    
    folders = []
    for folder_name in os.listdir(base_dir):
        folder_path = os.path.join(base_dir, folder_name)
        if os.path.isdir(folder_path):
            folders.append((folder_path, f"combined_{folder_name}.mp3"))
    
    print(f"Processing {len(folders)} folders with {max_threads} threads...")
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_threads) as executor:
        futures = []
        for folder_path, output_filename in folders:
            futures.append(executor.submit(process_folder, folder_path, output_filename))
        
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result:
                print(f"Successfully processed: {result}")
            else:
                print(f"Failed to process: {result}")

if __name__ == "__main__":
    main()

# Usage Examples:
# 1. Basic usage with default 3 threads:
#    python novel_to_audio.py novel_chapters
#
# 2. Specify custom thread count (5 threads):
#    python novel_to_audio.py novel_chapters --threads 5
#
# 3. Process novels in different directory:
#    python novel_to_audio.py /path/to/novel_chapters
#
# 4. Process with maximum threads (adjust based on CPU):
#    python novel_to_audio.py novel_chapters --threads 8