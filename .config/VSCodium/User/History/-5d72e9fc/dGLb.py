import os
import asyncio
import edge_tts
from vinorm import TTSnorm

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

async def process_folder(folder_path, output_filename):
    text_parts = []
    for filename in sorted(os.listdir(folder_path)):
        if filename.endswith('.txt'):
            with open(os.path.join(folder_path, filename), 'r', encoding='utf-8') as file:
                text_parts.append(file.read())
    combined_text = "\n\n".join(text_parts)
    normalized_text = normalize_vietnamese_text(combined_text)
    
    communicate = edge_tts.Communicate(normalized_text, "vi-VN-NamMinhNeural")
    await communicate.save(os.path.join(folder_path, output_filename))

async def main():
    base_dir = "novel_chapters"
    for folder_name in os.listdir(base_dir):
        folder_path = os.path.join(base_dir, folder_name)
        if os.path.isdir(folder_path):
            await process_folder(folder_path, f"combined_{folder_name}.mp3")

asyncio.run(main())