import asyncio
import random
import string
import logging

logging.basicConfig(level=30)

import nodriver as uc

async def main():

    browser = await uc.start(
        headless=False,
        browser_executable_path="/usr/bin/brave"
    )
    page = await browser.get('https://www.nowsecure.nl')

    await page.save_screenshot()
    await page.get_content()
    await page.scroll_down(150)
    elems = await page.select_all('*[src]')

    for elem in elems:
        await elem.flash()

    page2 = await browser.get('https://twitter.com', new_tab=True)
    page3 = await browser.get('https://github.com/ultrafunkamsterdam/nodriver', new_window=True)
    page4 = await browser.get('https://192.168.1.1', new_tab=True)
    page5 = await browser.get('https://searx.momoin.duckdns.org', new_tab=True)
    for p in (page, page2, page3):
        await p.bring_to_front()
        await p.scroll_down(200)
        await p   # wait for events to be processed
        await p.reload()
        await p.sleep(5)
        if p != page3:
            await p.reload()

if __name__ == '__main__':
    #asyncio.run
    # since asyncio.run never worked (for me)
    uc.loop().run_until_complete(main())