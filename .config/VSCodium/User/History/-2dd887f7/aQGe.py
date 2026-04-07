from firefox_selenium_helper import SeleniumHelper
from time import sleep
from random import randint
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path


def control_ssh():
    ssh_url = "http://127.0.0.1:8000/"
    strartall ="#startall"
    stopall = "#start"

    start_buttons =[]
    for btn_ in range(2, 7):
        start_btn = "#desc > tbody:nth-child(1) > tr:nth-child({0}) > td:nth-child(5) > button:nth-child(1)".format(str(btn_))
        start_buttons.append(start_btn)

    driver_ssh = SeleniumHelper(PROXY_PORT=1271)
    driver_ssh.loadPage(ssh_url)
    sleep(3)
    driver_ssh.clickSelector(stopall)
    sleep(1)
    driver_ssh.accept_alert()
    sleep(3)
    driver_ssh.clickSelector(strartall)
    sleep(1)
    driver_ssh.accept_alert()
    sleep(15)
    driver_ssh.refresh()
    while True:
        ok_port = 5
        for btn in start_buttons:
            if driver_ssh.existElement(btn):
                driver_ssh.clickSelector(btn)
                ok_port = ok_port - 1
        sleep(7)
        driver_ssh.refresh()
        if (ok_port == 5):
            break
    driver_ssh.close()

#url="https://www.xvideos.com/video62485863/old_man_fuck_teen_-_creampie"
def view_video(urls, PROXY_PORT, resultfile, viewcount):
    driver = SeleniumHelper(driverType='proxy', PROXY_PORT=PROXY_PORT)
    sleep(5)
    for url in urls:
        if (driver.loadPage(url)):
            sleep(randint(1,2))
            if driver.existElement('#disclaimer-over18btn'):
                driver.clickSelector('#disclaimer-over18btn')#ENTER_18
                sleep(randint(1,2))
            elif driver.existElement('#disclaimer_vpn_btns > a:nth-child(2) > span:nth-child(2)'):
                driver.clickSelector('#disclaimer_vpn_btns > a:nth-child(2) > span:nth-child(2)')#USA
                sleep(randint(6,10))
            #play_the_videos
            if driver.existWaitElement('div.big-button:nth-child(2) > img:nth-child(1)',wait=25):
                driver.clickSelector('div.buttons-bar:nth-child(5) > img:nth-child(3)') #double_player
                sleep(1)
                driver.clickSelector('div.big-button:nth-child(2) > img:nth-child(1)')#Play_big
                sleep(1)
                driver.driver.execute_script('window.scrollByLines(5)')
                sleep(randint(12,18))
            elif driver.existWaitElement('div.buttons-bar:nth-child(6) > img:nth-child(2)',wait=25):
                driver.clickSelector('div.buttons-bar:nth-child(5) > img:nth-child(3)') #double_player
                sleep(1)
                driver.clickSelector('div.buttons-bar:nth-child(6) > img:nth-child(2)')#Play_small
                sleep(1)
                driver.driver.execute_script('window.scrollByLines(6)')
                sleep(randint(12,18))
                
            #Error_loading_handle
            elif driver.existElement('.error-content > button:nth-child(2)'): #Error Loading
                driver.clickSelector('.error-content > button:nth-child(2)')
                sleep(randint(5,10))
                driver.waitAndClick('div.big-button:nth-child(2) > img:nth-child(1)',wait=50)#Play_big
                sleep(1)
                driver.clickSelector('div.buttons-bar:nth-child(7) > img:nth-child(3)') #double_player
                sleep(1)
                driver.driver.execute_script('window.scrollByLines(5)')
                sleep(randint(12,18))
                
            #Like_Dislike_Adclick_Random    
            like_rate = randint(1, 100)
            if like_rate > 1:
                driver.clickSelector('.thumb-up')#Like_Video
                sleep(randint(10,15))
            elif like_rate == 1:
                driver.clickSelector('.thumb-down')#DisLike_Video
                sleep(randint(10,15))   
            if like_rate > 85:
                driver.clickSelector('#video-ad > a:nth-child(1)')#Click_Ads_1
                sleep(randint(10,13))
            elif like_rate < 15:
                    driver.clickSelector('#video-ad > a:nth-child(2)')#Click_Ads_2
                    sleep(randint(10,13))

            driver.save_screenshot(resultfile)
            print('Done! ' + str(viewcount) + ' '+ url)
        else:
            print('####Error!####' + str(viewcount)+ ' '+ url)
    driver.close()
    sleep(1)

PORTS = []
views_amout = int(input('How many like: '))
for x in range(0, 5):
    port = 1271+x
    PORTS.append(port)

thread_numb = int(input('How many Threads(1-5): '))
with open(r'__view_urls.txt', 'r') as f:
    urls = [line.strip() for line in f]

""" cls = lambda: os.system('cls')
print("Paste URLS --> Ctrl+Z --> ENTER")
urls = []
while True:
    try:
        line = input()
    except EOFError:
        break
    urls.append(line)
cls() """
# path_to_profile_1 = Path(r".\Profiles\Xprofile1")
# path_to_profile_2 = Path(r".\Profiles\Xprofile2")
# path_to_profile_3 = Path(r".\Profiles\Xprofile3")
# path_to_profile_4 = Path(r".\Profiles\Xprofile4")
# path_to_profile_5 = Path(r".\Profiles\Xprofile5")
# path_to_profile_6 = Path(r".\Profiles\Xprofile6")
# path_to_profile_7 = Path(r".\Profiles\Xprofile7")
# path_to_profile_8 = Path(r".\Profiles\Xprofile8")
# path_to_profile_9 = Path(r".\Profiles\Xprofile9")
# path_to_profile_10 = Path(r".\Profiles\Xprofile10")

count_= 1
with ThreadPoolExecutor(max_workers=thread_numb) as pool:
    while (count_ <= views_amout):
        #control_ssh()
        for PORT in PORTS:
            if count_ < views_amout:
                pool.submit(view_video, urls, PORT, r".\Result\like_vid_{0}.png".format(str(PORT)), count_)
                count_ += 1
    pool.shutdown(wait=True)
input('Completed! Check result above')
