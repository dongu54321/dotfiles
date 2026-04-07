import asyncio

from openai import AsyncOpenAI
from openai.helpers import LocalAudioPlayer

openai = AsyncOpenAI(
    base_url="https://host.g4f.dev/v1",
    api_key="xC7CtreY6iNPYA6laLNnS1R8S6urkoSc938xuiBXWk4DECiXKMC3KOnqE3QlD3LfO3z5DMmqVCH6dPZRFHYH/fjsZZROuntAiWckboE5+maLjPa08fBxYRyTOWalmnvU4BXprdi8aIXW2hhEfLGXWzQdmKFKzdsiRykXHSbJC9SlLehVQVeybj/hFncICihgjYuDyA2kgmKuZJseGqPAGsNGXGrDoLaol7KY6dUph7ExYDFUCDANY4GzvASiR/6h/EylwOWFSzto/qV7xMJ/WYM4DEncrMSrzj+MvoSgc2wRzHUS1eNR9lHECMDC4uy/d+AXtaaTBxlc+WD9lWVvRbRAJ1KmhqObDXqyRkjHZhn9KPijTnph6CD1EfCQhWVUPaHO/L3EccQksXk0c49RshbPoIysvEVZulVHPgfr4zJRWVuLHGyTvdOru2q6l2VZf//XKmxNIaV43XuX9VrJ0enQYU6ylVRTn1pOV4W18J1v7JOlWTWS7GOFEivoyNVGzWLHBFIHio1NhRs5XVPSp3YN0uT9223KbjzPHSuoAXPTyQKLu8bkbsUscak/5/LK3dKLEdYo5NCInFHu09XyK+yk332ud3KQaHEHGEMplwwWLetnhWhIXc0gk06VvhydCT8I88JSsupoCMCUYMv4m0UVnEAkeyGkV4acQLDMXzk="  # Replace with your actual API key
)

# Read input from text.txt file
with open("text.txt", "r", encoding="utf-8") as f:
    input = f.read()

instructions = """Voice Affect: Low, hushed, and suspenseful; convey tension and intrigue.\n\nTone: Deeply serious and mysterious, maintaining an undercurrent of unease throughout.\n\nPacing: Slow, deliberate, pausing slightly after suspenseful moments to heighten drama.\n\nEmotion: Restrained yet intense—voice should subtly tremble or tighten at key suspenseful points.\n\nEmphasis: Highlight sensory descriptions (\"footsteps echoed,\" \"heart hammering,\" \"shadows melting into darkness\") to amplify atmosphere.\n\nPronunciation: Slightly elongated vowels and softened consonants for an eerie, haunting effect.\n\nPauses: Insert meaningful pauses after phrases like \"only shadows melting into darkness,\" and especially before the final line, to enhance suspense dramatically."""

async def main() -> None:

    async with openai.audio.speech.with_streaming_response.create(
        model="gpt-4o-mini-tts",
        voice="coral",
        input=input,
        instructions=instructions,
        response_format="pcm",
    ) as response:
        await LocalAudioPlayer().play(response)

if __name__ == "__main__":
    asyncio.run(main())