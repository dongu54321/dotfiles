import asyncio

from openai import AsyncOpenAI
from openai.helpers import LocalAudioPlayer

openai = AsyncOpenAI()

input = """The night was thick with fog, wrapping the town in mist. Detective Evelyn Harper pulled her coat tighter, feeling the chill creep down her spine. She knew the town's buried secrets were rising again.\n\nFootsteps echoed behind her, slow and deliberate. She turned, heart racing, but saw only shadows.\n\nEvelyn steadied her breath—tonight felt different. Tonight, the danger felt personal. Somewhere nearby, hidden eyes watched her every move. Waiting. Planning. Knowing her next step.\n\nThis was just the beginning."""

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