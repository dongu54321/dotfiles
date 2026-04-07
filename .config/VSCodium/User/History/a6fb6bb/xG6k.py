import os
import re
import time
import requests
from bs4 import BeautifulSoup
from vinorm import TTSnorm

# Configuration
NOVEL_URLS = [
    "https://truyen.tangthuvien.vn/doc-truyen/dichtoi-cuong-he-thong-suu-tam/chuong-",
    "https://truyen.tangthuvien.vn/doc-truyen/thuy-nhuong-tha-tu-tien-dich!--ai-bao-han-tu-tien!/chuong-",
    "https://truyen.tangthuvien.vn/doc-truyen/dai-thua-ky-moi-co-nghich-tap-he-thong/chuong-"
]
DELAY_SECONDS = 1
EXACT_MATCHES_TO_REMOVE = [
    "oOo", "-----oo0oo-----", "---oo0oo---", "***", "-----", "----", "---", 
    "o0o", "OoO", "End chapter", "Hết chương", "—–oo0oo—–​"
]
PREFIXES_TO_REMOVE = [
    "Dịch giả:", "Biên tập:", "Nhóm dịch:", "Dịch:", "Biên:", "Nhóm:", "----", "Người dịch:", "Team dịch:", "Dịch & biên:", 
    "Dich:", ""
]

def normalize_vietnamese_text(text):
    """Normalize Vietnamese text using TTSnorm and custom rules"""
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

def sanitise_filename(title):
    """Remove invalid characters from filename"""
    return re.sub(r'[\\/*?:"<>|]', '', title).strip()

def get_chapter_group(chapter_num):
    """Determine folder name for chapter grouping (001-100, 101-200, etc)"""
    group_start = ((chapter_num - 1) // 100) * 100 + 1
    group_end = group_start + 99
    return f"{group_start:03d}-{group_end:03d}"

def get_novel_slug(url):
    """Extract novel slug from URL"""
    parts = url.split('/')
    try:
        doc_index = parts.index('doc-truyen')
        return parts[doc_index + 1]
    except (ValueError, IndexError):
        return [p for p in parts if p][-2]

def get_last_chapter(novel_slug):
    """Get last scraped chapter for a novel"""
    resume_file = f"last_chapter_{novel_slug}.txt"
    try:
        with open(resume_file, 'r') as f:
            content = f.read().strip()
            if content == "completed":
                return -1  # Novel completed marker
            return int(content)
    except FileNotFoundError:
        return 0

def mark_novel_completed(novel_slug):
    """Mark a novel as fully downloaded"""
    resume_file = f"last_chapter_{novel_slug}.txt"
    with open(resume_file, 'w') as f:
        f.write("completed")

def save_chapter(novel_slug, chapter_num, title, content):
    """Save chapter content to appropriate file"""
    group_folder = get_chapter_group(chapter_num)
    dir_path = os.path.join(novel_slug, group_folder)
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
        
        if not stripped:
            continue
            
        if stripped in EXACT_MATCHES_TO_REMOVE:
            continue
            
        if any(stripped.startswith(prefix) for prefix in PREFIXES_TO_REMOVE):
            continue
            
        cleaned_lines.append(line)
        
    return '\n'.join(cleaned_lines)

def scrape_chapter(base_url, novel_slug, chapter_num):
    """Scrape and normalize a single chapter"""
    url = f"{base_url}{chapter_num}"
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
    
    # Clean and normalize content
    raw_content = content_div.get_text()
    cleaned_content = clean_content(raw_content)
    normalized_content = normalize_vietnamese_text(cleaned_content)
    
    save_chapter(novel_slug, chapter_num, title, normalized_content)
    
    return True

def update_resume_file(novel_slug, chapter_num):
    """Update resume file with current chapter number"""
    resume_file = f"last_chapter_{novel_slug}.txt"
    with open(resume_file, 'w') as f:
        f.write(str(chapter_num))

def scrape_novel(base_url):
    """Scrape all chapters for a single novel"""
    novel_slug = get_novel_slug(base_url)
    print(f"\nProcessing novel: {novel_slug}")
    
    # Check if novel is already completed
    last_chapter = get_last_chapter(novel_slug)
    if last_chapter == -1:
        print(f"  - Already completed, skipping")
        return True
    
    current_chapter = last_chapter + 1 if last_chapter > 0 else 1
    print(f"  - Starting from chapter {current_chapter}")
    
    consecutive_failures = 0
    while consecutive_failures < 3:  # Stop after 3 consecutive failures
        print(f"  - Scraping chapter {current_chapter}...")
        success = scrape_chapter(base_url, novel_slug, current_chapter)
        
        if success:
            # Update resume file and reset failure counter
            update_resume_file(novel_slug, current_chapter)
            current_chapter += 1
            consecutive_failures = 0
            time.sleep(DELAY_SECONDS)
        else:
            consecutive_failures += 1
            print(f"  - Failed to scrape chapter {current_chapter} (attempt {consecutive_failures}/3)")
            
            # If first chapter fails, novel might not exist
            if current_chapter == 1 and consecutive_failures >= 3:
                print("  - Novel appears unavailable, skipping")
                return False
            
            time.sleep(DELAY_SECONDS * 2)  # Longer delay on failure
    
    # If we exited due to failures, mark novel as completed
    if consecutive_failures >= 3:
        print(f"  - Reached end of novel at chapter {current_chapter-1}")
        mark_novel_completed(novel_slug)
        return True
    
    return False

def main():
    """Scrape all novels in the list"""
    print(f"Starting novel download with {len(NOVEL_URLS)} novels")
    
    for i, novel_url in enumerate(NOVEL_URLS):
        print(f"\n=== Novel {i+1}/{len(NOVEL_URLS)} ===")
        try:
            completed = scrape_novel(novel_url)
            if completed:
                print(f"  - Novel completed successfully")
            else:
                print(f"  - Novel processing stopped")
        except Exception as e:
            print(f"  - Error scraping novel: {str(e)}")
    
    print("\nAll novels processed")

if __name__ == "__main__":
    main()