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
DELAY = 1  # seconds between requests (be kind to server)

# Create folder to store chapters
OUTPUT_FOLDER = "novel_chapters"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def clean_filename(name):
    """Remove invalid characters for filenames"""
    name = re.sub(r'[\\/*?:"<>|]', "", name)
    name = name.strip().replace('\n', ' ').replace('\r', '')
    return name[:150]  # limit length

def scrape_chapter(url):
    try:
        print(f"📖 Fetching: {url}")
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
    except Exception as e:
        print(f"❌ Failed to fetch {url}: {e}")
        return None, None, None

    soup = BeautifulSoup(response.text, 'html.parser')

    # ===== EXTRACT TITLE =====
    content_div = soup.find('div', class_='content')
    if not content_div:
        print("⚠️  No 'div.content' found.")
        return None, None, None

    h2_tag = content_div.find('h2')
    if h2_tag:
        title = h2_tag.get_text(strip=True)
    else:
        # Fallback: use URL or generic title
        title = "Chapter_" + url.split('/')[-1]

    title = clean_filename(title)

    # ===== EXTRACT CONTENT =====
    # Get all <p> tags inside content_div, excluding <script> and ads
    paragraphs = []
    for elem in content_div.find_all(['p', 'h2'], recursive=False):
        # Skip if inside <script> or ad containers
        if elem.find_parent('script') or 'adsbygoogle' in elem.get('class', []):
            continue
        text = elem.get_text(strip=True)
        if text and not text.startswith(('-----', 'oOo', '---', '***')):
            paragraphs.append(text)

    # Join paragraphs with newlines
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
        # else: relative path we can't resolve → ignore

    return title, content, next_url

def save_to_file(title, content):
    filename = f"{title}.txt"
    filepath = os.path.join(OUTPUT_FOLDER, filename)

    # Avoid filename collision
    counter = 1
    original_filepath = filepath
    while os.path.exists(filepath):
        name, ext = os.path.splitext(original_filepath)
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