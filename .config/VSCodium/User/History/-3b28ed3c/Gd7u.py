import requests
from bs4 import BeautifulSoup
import time
import os
import re

# ===== CONFIG =====
START_URL = "https://tamhoan.com/toi-cuong-he-thong/420008"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
}
DELAY = 1  # seconds between requests

OUTPUT_FOLDER = "novel_chapters"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def clean_filename(name):
    name = re.sub(r'[\\/*?:"<>|]', "", name)
    return name.strip().replace('\n', ' ').replace('\r', '')[:150]

def scrape_chapter(url):
    try:
        print(f"📖 Fetching: {url}")
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
    except Exception as e:
        print(f"❌ Failed to fetch {url}: {e}")
        return None, None, None

    soup = BeautifulSoup(response.text, 'html.parser')

    # ===== TARGET: div.content =====
    content_div = soup.find('div', class_='content')
    if not content_div:
        print("⚠️  No div with class 'content' found.")
        return None, None, None

    # ===== EXTRACT TITLE from <h2> inside .content =====
    h2_tag = content_div.find('h2')
    title = h2_tag.get_text(strip=True) if h2_tag else f"Chapter_{url.split('/')[-1]}"
    title = clean_filename(title)

    # ===== EXTRACT FULL TEXT CONTENT =====
    # Clone the content div to avoid modifying original
    content_clone = BeautifulSoup(str(content_div), 'html.parser')

    # Remove <script> tags and ad containers
    for script in content_clone.find_all('script'):
        script.decompose()
    for ad in content_clone.find_all(class_=lambda c: c and 'adsbygoogle' in c):
        ad.decompose()
    for ins in content_clone.find_all('ins'):
        ins.decompose()

    # Get all direct children that are block-level text containers
    paragraphs = []
    for elem in content_clone.find_all(['p', 'h2', 'h3', 'h4', 'div'], recursive=False):
        # Skip empty or ad-related
        if not elem.get_text(strip=True):
            continue
        # Get clean text
        text = elem.get_text(strip=False)  # preserve internal spacing
        paragraphs.append(text.strip())

    # If no paragraphs found, fallback: get all text from content_div (excluding scripts)
    if not paragraphs:
        print("⚠️  No paragraphs found. Using full text fallback.")
        text = content_div.get_text(separator='\n', strip=False)
        # Remove ad scripts manually
        lines = [
            line.strip() for line in text.split('\n')
            if not line.strip().startswith(('-----', '***', 'oOo'))  # optional: keep these if you want
        ]
        content = "\n\n".join(line for line in lines if line)
    else:
        content = "\n\n".join(paragraphs)

    # ===== FIND NEXT CHAPTER =====
    next_chap_tag = soup.find('a', id='next_chap')
    next_url = None
    if next_chap_tag and next_chap_tag.get('href'):
        href = next_chap_tag['href']
        if href.startswith('/'):
            next_url = 'https://tamhoan.com' + href
        elif href.startswith('http'):
            next_url = href

    return title, content, next_url

def save_to_file(title, content):
    filename = f"{title}.txt"
    filepath = os.path.join(OUTPUT_FOLDER, filename)

    counter = 1
    original_name = filepath
    while os.path.exists(filepath):
        name, ext = os.path.splitext(original_name)
        filepath = f"{name}_{counter}{ext}"
        counter += 1

    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Saved: {filepath}")
    except Exception as e:
        print(f"❌ Failed to save {filepath}: {e}")

def main():
    current_url = START_URL
    visited = set()

    while current_url:
        if current_url in visited:
            print("🔁 Loop detected. Stopping.")
            break
        visited.add(current_url)

        title, content, next_url = scrape_chapter(current_url)

        if not title or not content:
            print("🛑 Missing title or content. Stopping.")
            break

        save_to_file(title, content)

        if not next_url:
            print("🔚 No next chapter. Done!")
            break

        current_url = next_url
        print(f"⏳ Waiting {DELAY} sec before next request...")
        time.sleep(DELAY)

if __name__ == "__main__":
    main()