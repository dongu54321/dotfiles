import os
import re
import time
import requests
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from vinorm import TTSnorm

# Configuration
DELAY_SECONDS = 0.5  # Reduced delay since we're using multithreading
PROXIES = [
    {"http": "http://127.0.0.1:18888", "https": "http://127.0.0.1:18888"},
    {"http": "http://127.0.0.1:18886", "https": "http://127.0.0.1:18886"},
    {"http": "http://127.0.0.1:18880", "https": "http://127.0.0.1:18880"},
]
MAX_WORKERS = 4  # 3 proxies + 1 direct connection
CHAPTERS_PER_BATCH = 10  # Number of chapters to process in each batch

EXACT_MATCHES_TO_REMOVE = [
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
    "—–oo0oo—–​",
]
PREFIXES_TO_REMOVE = [
    "Dịch giả:",
    "Biên tập:",
    "Nhóm dịch:",
    "Dịch:",
    "Biên:",
    "Nhóm:",
    "----",
    "Người dịch:",
    "Team dịch:",
    "Dịch & biên:",
    "Dich:",
    "—–",
]


class NovelScraper:
    def __init__(self):
        self.site_configs = {
            "truyen.tangthuvien.vn": {
                "title_selector": "h2",
                "content_selector": 'div[class^="box-chap"]',
                "title_process": self._process_tangthuvien_title,
                "url_pattern": r"/chuong-(\d+)$",
                "url_generator": self._generate_tangthuvien_url,
            },
            "truyenfullmoi.com": {
                "title_selector": "a.chapter-title",
                "content_selector": "div#chapter-c",
                "title_process": self._process_truyenfull_title,
                "url_pattern": r"/chuong-(\d+)\.html$",
                "url_generator": self._generate_truyenfull_url,
            },
        }
        self.lock = threading.Lock()  # For thread-safe file operations

    def _process_tangthuvien_title(self, title_element):
        """Process title for tangthuvien.vn"""
        title = title_element.get_text().replace("&nbsp;", " ").strip()
        return title

    def _process_truyenfull_title(self, title_element):
        """Process title for truyenfullmoi.com"""
        title = title_element.get_text().strip()
        return title

    def _generate_tangthuvien_url(self, base_url, chapter_num):
        """Generate URL for tangthuvien.vn"""
        base_clean = re.sub(r"/chuong-\d+/?$", "", base_url.rstrip("/"))
        return f"{base_clean}/chuong-{chapter_num}"

    def _generate_truyenfull_url(self, base_url, chapter_num):
        """Generate URL for truyenfullmoi.com"""
        base_clean = re.sub(r"/chuong-\d+\.html?$", "", base_url.rstrip("/"))
        return f"{base_clean}/chuong-{chapter_num}.html"

    def normalize_vietnamese_text(self, text):
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

    def sanitise_filename(self, title):
        """Remove invalid characters from filename"""
        return re.sub(r'[\\/*?:"<>|]', "", title).strip()

    def get_chapter_group(self, chapter_num):
        """Determine folder name for chapter grouping (001-100, 101-200, etc)"""
        group_start = ((chapter_num - 1) // 100) * 100 + 1
        group_end = group_start + 99
        return f"{group_start:03d}-{group_end:03d}"

    def get_novel_slug(self, url):
        """Extract novel slug from URL"""
        clean_url = re.sub(r"/chuong-\d+\.?html?$", "", url.rstrip("/"))

        parsed = urlparse(clean_url)
        domain = parsed.netloc.lower()

        if "truyen.tangthuvien.vn" in domain:
            parts = clean_url.split("/")
            try:
                doc_index = parts.index("doc-truyen")
                return parts[doc_index + 1]
            except (ValueError, IndexError):
                for part in reversed(parts):
                    if part and part not in ["https:", "http:", ""]:
                        return part
        elif "truyenfullmoi.com" in domain:
            parts = clean_url.split("/")
            for part in reversed(parts):
                if part and part not in ["https:", "http:", ""]:
                    return part
        parts = clean_url.split("/")
        for part in reversed(parts):
            if part and part not in ["https:", "http:", ""]:
                return part
        return "unknown_novel"

    def get_last_chapter(self, novel_slug):
        """Get last scraped chapter for a novel"""
        resume_file = os.path.join(novel_slug, "resume.lst")
        try:
            with open(resume_file, "r") as f:
                content = f.read().strip()
                if content == "completed":
                    return -1  # Novel completed marker
                return int(content)
        except FileNotFoundError:
            return 0

    def mark_novel_completed(self, novel_slug):
        """Mark a novel as fully downloaded"""
        resume_file = os.path.join(novel_slug, "resume.lst")
        with self.lock:  # Thread-safe file operation
            os.makedirs(os.path.dirname(resume_file), exist_ok=True)
            with open(resume_file, "w") as f:
                f.write("completed")

    def save_chapter(self, novel_slug, chapter_num, title, content):
        """Save chapter content with title at top"""
        group_folder = self.get_chapter_group(chapter_num)
        dir_path = os.path.join(novel_slug, group_folder)

        with self.lock:  # Thread-safe file operation
            os.makedirs(dir_path, exist_ok=True)

        filename = f"{chapter_num:03d}. {self.sanitise_filename(title)}.txt"
        file_path = os.path.join(dir_path, filename)

        # Format: Chapter title + blank line + content
        with self.lock:  # Thread-safe file operation
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(title + "\n\n" + content)

    def clean_content(self, content):
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

        return "\n".join(cleaned_lines)

    def get_site_config(self, url):
        """Get site configuration based on URL"""
        parsed = urlparse(url)
        domain = parsed.netloc.lower()

        for site_domain in self.site_configs:
            if site_domain in domain:
                return self.site_configs[site_domain]

        # Default configuration for unknown sites
        return {
            "title_selector": "h2",
            "content_selector": 'div[class^="box-chap"]',
            "title_process": self._process_tangthuvien_title,
            "url_pattern": r"/chuong-(\d+)$",
            "url_generator": self._generate_tangthuvien_url,
        }

    def scrape_chapter(self, base_url, novel_slug, chapter_num, proxy=None):
        """Scrape and normalize a single chapter"""
        config = self.get_site_config(base_url)
        url = config["url_generator"](base_url, chapter_num)

        try:
            # Prepare request parameters
            request_params = {
                "url": url,
                "timeout": 15,
                "headers": {
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                },
            }

            if proxy:
                request_params["proxies"] = proxy

            response = requests.get(**request_params)
            if response.status_code != 200:
                return False, chapter_num

            soup = BeautifulSoup(response.content, "html.parser")

            # Extract title
            title_tag = soup.select_one(config["title_selector"])
            if not title_tag:
                return False, chapter_num
            title = config["title_process"](title_tag)

            # Extract content
            content_div = soup.select_one(config["content_selector"])
            if not content_div:
                return False, chapter_num

            # Clean and normalize content
            raw_content = content_div.get_text()
            cleaned_content = self.clean_content(raw_content)
            normalized_content = self.normalize_vietnamese_text(cleaned_content)

            self.save_chapter(novel_slug, chapter_num, title, normalized_content)

            return True, chapter_num
        except Exception as e:
            return False, chapter_num

    def update_resume_file(self, novel_slug, chapter_num):
        """Update resume file with current chapter number"""
        resume_file = os.path.join(novel_slug, "resume.lst")
        with self.lock:  # Thread-safe file operation
            os.makedirs(os.path.dirname(resume_file), exist_ok=True)
            with open(resume_file, "w") as f:
                f.write(str(chapter_num))

    def scrape_novel_batch(self, base_url, novel_slug, chapter_numbers, proxies):
        """Scrape a batch of chapters using multiple threads"""
        results = {}
        proxy_cycle = proxies + [None]  # Include None for direct connection

        with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
            future_to_chapter = {}
            for i, chapter_num in enumerate(chapter_numbers):
                proxy = proxy_cycle[i % len(proxy_cycle)]  # Rotate proxies
                future = executor.submit(
                    self.scrape_chapter, base_url, novel_slug, chapter_num, proxy
                )
                future_to_chapter[future] = chapter_num

            for future in as_completed(future_to_chapter):
                chapter_num = future_to_chapter[future]
                try:
                    success, chap_num = future.result()
                    results[chap_num] = success
                except Exception as e:
                    results[chapter_num] = False

        return results

    def scrape_novel(self, base_url):
        """Scrape all chapters for a single novel using multithreading"""
        novel_slug = self.get_novel_slug(base_url)
        print(f"\nProcessing novel: {novel_slug}")

        # Check if novel is already completed
        last_chapter = self.get_last_chapter(novel_slug)
        if last_chapter == -1:
            print(f"  - Already completed, skipping")
            return True

        current_chapter = last_chapter + 1 if last_chapter > 0 else 1
        print(f"  - Starting from chapter {current_chapter}")

        consecutive_failures = 0
        while consecutive_failures < 3:
            # Create batch of chapters to scrape
            chapter_batch = list(
                range(current_chapter, current_chapter + CHAPTERS_PER_BATCH)
            )
            print(f"  - Scraping chapters {chapter_batch[0]}-{chapter_batch[-1]}...")

            # Scrape batch
            results = self.scrape_novel_batch(
                base_url, novel_slug, chapter_batch, PROXIES
            )

            # Process results
            success_count = 0
            for chapter_num in sorted(results.keys()):
                if results[chapter_num]:
                    self.update_resume_file(novel_slug, chapter_num)
                    success_count += 1
                else:
                    print(f"    - Failed to scrape chapter {chapter_num}")

            # Update counters
            if success_count > 0:
                current_chapter += success_count
                consecutive_failures = 0
            else:
                consecutive_failures += 1
                print(
                    f"  - No chapters scraped successfully (attempt {consecutive_failures}/3)"
                )
                time.sleep(DELAY_SECONDS * 4)  # Longer delay on failure

            # Small delay between batches
            time.sleep(DELAY_SECONDS)

        # If we exited due to failures, mark novel as completed
        if consecutive_failures >= 3:
            print(f"  - Reached end of novel at chapter {current_chapter-1}")
            self.mark_novel_completed(novel_slug)
            return True

        return False

    def load_novel_urls(self):
        """Load novel URLs from novel_list.txt file"""
        try:
            with open("novel_list.txt", "r") as f:
                return [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            print("Error: novel_list.txt not found")
            return []

    def run(self):
        """Scrape all novels from novel_list.txt"""
        novel_urls = self.load_novel_urls()
        if not novel_urls:
            print("No novels to download. Create novel_list.txt with URLs.")
            return

        print(
            f"Starting novel download with {len(novel_urls)} novels using {MAX_WORKERS} threads"
        )

        for i, novel_url in enumerate(novel_urls):
            print(f"\n=== Novel {i+1}/{len(novel_urls)} ===")
            try:
                completed = self.scrape_novel(novel_url)
                if completed:
                    print(f"  - Novel completed successfully")
                else:
                    print(f"  - Novel processing stopped")
            except Exception as e:
                print(f"  - Error scraping novel: {str(e)}")

        print("\nAll novels processed")


def main():
    """Main entry point"""
    scraper = NovelScraper()
    scraper.run()


if __name__ == "__main__":
    main()
