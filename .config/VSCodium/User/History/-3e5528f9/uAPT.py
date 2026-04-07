import asyncio
import random
import string
import logging

logging.basicConfig(level=30)

import nodriver as uc

async def main():
    browser = await uc.start(
        headless=False,
        browser_executable_path="/home/vugia/Downloads/chrome-lin/chrome",
        browser_args=['--ignore-certificate-errors', '--window-size=1600,900'],
    )
    tab = await browser.get('https://192.168.1.1')
    print("finding the name input field")
    name = await tab.select("input[type=text]")
    print('filling in the "name" input field')
    await name.send_keys('admin')

    print("finding the password input field")
    passwd_field = await tab.select("#txt_Password")
    await passwd_field.send_keys('h33A$2gvj2gr4U7avic9MQGF849r')

    # print('finding the "create account" button')
    print('clicking the "login" button')
    login = await tab.find("Login", best_match=True)
    await login.click()

    Advanced_Setup = await tab.select("#Cmbutton")
    await Advanced_Setup.click()

    print('click IPv6')
    IPv6 = await tab.find("IPv6")
    await IPv6.click()

    print('click port mapping')
    PortM= await tab.find("Port Mapping")
    await PortM.click()

    print('click container')
    await tab.sleep(3)
    container = await tab.find("Container")
    await container.click()

    print('read ipv6 files')
    with open(r'ip.txt', 'r') as f:
        ip6 = f.readlines()
    await tab.sleep(2)

    tab = await browser.get('https://192.168.1.1/html/bbsp/ipv6portmapping/ipv6portmapping.asp')
    print('click container')
    container = await tab.find("Container")
    await container.click()
    print('filling ',ip6[0])
    field = await tab.select("#InternalClient")
    # await field.focus()
    await field.click()
    await field.clear_input()
    await tab.sleep(2)
    await field.click()
    await field.send_keys(ip6[0])
    await tab.sleep(2)

    print('click apply button')
    applybtn = await tab.select("#btnApply_ex")
    await applybtn.click()
    await tab.sleep(5)
    tab = await tab.get('https://192.168.1.1/index.asp')
    await tab.sleep(2)
    print('Logout')
    logout = await tab.find("Logout")
    await tab.sleep(2)
    await logout.click()
    await tab.close()
if __name__ == "__main__":
    # since asyncio.run never worked (for me)
    # i use
    uc.loop().run_until_complete(main())
