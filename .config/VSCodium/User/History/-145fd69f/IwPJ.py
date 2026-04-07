import requests
from bs4 import BeautifulSoup
import time
import os
import re

# ===== CONFIG =====
# chap1 url
START_URL = "https://tamhoan.com/toi-cuong-he-thong/419898"
OUTPUT_FOLDER = "toi-cuong-he-thong"
DELAY = 1  # seconds between requests
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
}
LAST_CHAPTER_FILE = "last_chapter_url.txt"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)


def get_folder_name(chapter_number, chapters_per_folder=100):
    """
    Calculate which folder a chapter should go into
    """
    if chapter_number is None:
        return "unknown"
    folder_start = (
        (chapter_number - 1) // chapters_per_folder
    ) * chapters_per_folder + 1
    folder_end = folder_start + chapters_per_folder - 1
    return f"{folder_start}-{folder_end}"


def extract_chapter_number(title):
    """
    Extracts chapter number from title like "Chương 81: ...", returns 81.
    If not found, returns None.
    """
    match = re.search(r"[cC]hương\s*(\d+)", title)
    if match:
        return int(match.group(1))
    # Try digits at start: "81: ..." or "Chapter 81"
    match = re.search(r"^\s*(\d+)", title)
    if match:
        return int(match.group(1))
    return None


def clean_filename(name):
    name = re.sub(r'[\\/*?:"<>|]', "", name)
    return name.strip().replace("\n", " ").replace("\r", "")[:150]


def save_last_url(url):
    with open(LAST_CHAPTER_FILE, "w") as f:
        f.write(url)


# Add this to load the last URL at startup
def load_last_url():
    try:
        with open(LAST_CHAPTER_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        return None


def scrape_chapter(url):
    try:
        print(f"📖 Fetching: {url}")
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
    except Exception as e:
        print(f"❌ Failed to fetch {url}: {e}")
        return None, None, None

    soup = BeautifulSoup(response.text, "html.parser")

    # ===== TARGET: div.content =====
    content_div = soup.find("div", class_="content")
    if not content_div:
        print("⚠️  No div with class 'content' found.")
        return None, None, None

    # ===== EXTRACT TITLE from <h2> inside .content =====
    h2_tag = content_div.find("h2")
    title = h2_tag.get_text(strip=True) if h2_tag else f"Chapter_{url.split('/')[-1]}"
    title = clean_filename(title)

    # ===== EXTRACT & CLEAN CONTENT =====
    # Clone to avoid modifying original
    content_clone = BeautifulSoup(str(content_div), "html.parser")

    # Remove ads and scripts
    for script in content_clone.find_all("script"):
        script.decompose()
    for ad in content_clone.find_all(class_=lambda c: c and "adsbygoogle" in c):
        ad.decompose()
    for ins in content_clone.find_all("ins"):
        ins.decompose()

    # Define separators to remove (customize this list as needed)
    SEPARATORS_TO_REMOVE = [
        "oOo",
        "-----oo0oo-----",
        "---oo0oo---",
        "***",
        "-----",
        "----",
        "---",
        "o0o",
        "OoO",
        "End chapter",
        "Hết chương",
    ]

    paragraphs = []

    # Extract all direct children that may contain text
    # for elem in content_clone.find_all(["p", "div", "h3", "h4"], recursive=False):
    #     text = elem.get_text(strip=True)  # strip whitespace

    #     # Skip if empty
    #     if not text:
    #         continue

    #     # Skip if it's a separator
    #     if any(sep in text for sep in SEPARATORS_TO_REMOVE):
    #         continue

    #     # Add paragraph — we’ll join with \n\n later
    #     paragraphs.append(text)

    # If no paragraphs found, fallback to full text extraction (cleaned)
    if not paragraphs:
        #print("⚠️  No valid paragraphs found. Using full text cleanup fallback.")
        full_text = content_div.get_text(separator="\n", strip=False)
        lines = full_text.split("\n")
        cleaned_lines = []
        for line in lines:
            stripped = line.strip()
            if not stripped:
                continue
            if any(sep in stripped for sep in SEPARATORS_TO_REMOVE):
                continue
            cleaned_lines.append(stripped)
        content = "\n\n".join(cleaned_lines)
    else:
        content = "\n\n".join(paragraphs)

    # ===== FIND NEXT CHAPTER =====
    next_chap_tag = soup.find("a", id="next_chap")
    next_url = None
    if next_chap_tag and next_chap_tag.get("href"):
        href = next_chap_tag["href"]
        if href.startswith("/"):
            next_url = "https://tamhoan.com" + href
        elif href.startswith("http"):
            next_url = href

    return title, content, next_url


def save_to_file(title, content):
    # Extract chapter number for prefix and folder organization
    chap_num = extract_chapter_number(title)

    # Determine folder path
    folder_name = get_folder_name(chap_num)
    folder_path = os.path.join(OUTPUT_FOLDER, folder_name)
    os.makedirs(folder_path, exist_ok=True)

    if chap_num is not None:
        prefix = f"{chap_num:03d}. "  # → "081. "
        filename = f"{prefix}{title}.txt"
    else:
        filename = f"{title}.txt"

    filename = clean_filename(filename)  # still clean invalid chars
    filepath = os.path.join(folder_path, filename)

    # Avoid overwrites
    counter = 1
    original_filepath = filepath
    while os.path.exists(filepath):
        name, ext = os.path.splitext(original_filepath)
        filepath = f"{name}_{counter}{ext}"
        counter += 1

    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Saved: {filepath}")
    except Exception as e:
        print(f"❌ Failed to save {filepath}: {e}")


def main():
    saved_url = load_last_url()
    current_url = saved_url if saved_url else START_URL
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
        save_last_url(current_url)  # Save progress
        if not next_url:
            print("🔚 No next chapter. Done!")
            break

        current_url = next_url
        print(f"⏳ Waiting {DELAY} sec before next request...")
        time.sleep(DELAY)


if __name__ == "__main__":
    main()
