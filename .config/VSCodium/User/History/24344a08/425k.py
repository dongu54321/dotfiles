import os
import re
import time
import requests
from bs4 import BeautifulSoup

# Configuration
BASE_URL = "https://truyen.tangthuvien.vn/doc-truyen/dichtoi-cuong-he-thong-suu-tam/chuong-"
NOVEL_NAME = "dichtoi-cuong-he-thong-suu-tam"
RESUME_FILE = "last_chapter.txt"
DELAY_SECONDS = 1  # Delay between requests to avoid blocking
EXACT_MATCHES_TO_REMOVE = [
    "oOo", "-----oo0oo-----", "---oo0oo---", "***", "-----", "----", "---",
    "o0o", "OoO", "End chapter", "Hết chương"
]
PREFIXES_TO_REMOVE = [
    "Dịch giả:", "Biên tập:", "Nhóm dịch:", "Dịch:", "Biên:", "Nhóm:", "----"
]

def sanitise_filename(title):
    """Remove invalid characters from filename"""
    return re.sub(r'[\\/*?:"<>|]', '', title).strip()

def get_chapter_group(chapter_num):
    """Determine folder name for chapter grouping (001-100, 101-200, etc)"""
    group_start = ((chapter_num - 1) // 100) * 100 + 1
    group_end = group_start + 99
    return f"{group_start:03d}-{group_end:03d}"

def get_last_chapter():
    """Get last scraped chapter from resume file"""
    try:
        with open(RESUME_FILE, 'r') as f:
            return int(f.read().strip())
    except FileNotFoundError:
        return 0

def save_chapter(chapter_num, title, content):
    """Save chapter content to appropriate file"""
    group_folder = get_chapter_group(chapter_num)
    dir_path = os.path.join(NOVEL_NAME, group_folder)
    os.makedirs(dir_path, exist_ok=True)
    
    filename = f"{chapter_num:03d}. {sanitise_filename(title)}.txt"
    file_path = os.path.join(dir_path, filename)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def clean_content(content):
    """Remove unwanted separators and translator lines"""
    cleaned_lines = []
    for line in content.splitlines():
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            continue
            
        # Skip exact matches
        if stripped in EXACT_MATCHES_TO_REMOVE:
            continue
            
        # Skip lines starting with translator prefixes
        if any(stripped.startswith(prefix) for prefix in PREFIXES_TO_REMOVE):
            continue
            
        cleaned_lines.append(line)
        
    return '\n'.join(cleaned_lines)

def scrape_chapter(chapter_num):
    """Scrape a single chapter"""
    url = f"{BASE_URL}{chapter_num}"
    response = requests.get(url)
    if response.status_code != 200:
        return False
    
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Extract title
    title_tag = soup.find('h2')
    if not title_tag:
        return False
    title = title_tag.get_text().replace('&nbsp;', ' ').strip()
    
    # Extract content
    content_div = soup.find('div', class_=lambda x: x and x.startswith('box-chap'))
    if not content_div:
        return False
    
    content = clean_content(content_div.get_text())
    save_chapter(chapter_num, title, content)
    
    # Update resume file
    with open(RESUME_FILE, 'w') as f:
        f.write(str(chapter_num))
    
    return True

def main():
    current_chapter = get_last_chapter() + 1
    while True:
        print(f"Scraping chapter {current_chapter}...")
        if not scrape_chapter(current_chapter):
            print(f"Stopped at chapter {current_chapter-1}")
            break
        current_chapter += 1
        time.sleep(DELAY_SECONDS)  # Add delay between requests

if __name__ == "__main__":
    main()