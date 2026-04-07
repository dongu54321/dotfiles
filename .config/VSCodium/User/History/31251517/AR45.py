from helium import *
from time import sleep
Config.implicit_wait_secs = 25

import time
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.remote.webdriver import By
import selenium.webdriver.support.expected_conditions as EC  # noqa
from selenium.webdriver.support.wait import WebDriverWait
# from selenium import webdriver
# from selenium.webdriver.common.proxy import Proxy
# from selenium.webdriver.common.proxy import ProxyType
import undetected_chromedriver as uc

chrome = uc.Chrome(
    browser_executable_path="/home/vugia/Downloads/chrome-lin/chrome",
    browser_args=['--no-sandbox', '--window-size=1600,900'],
)

set_driver(chrome)
go_to('https://workupload.com/')
time.sleep(2)
# start_firefox('https://workupload.com/')

#drag_file(r"C:\\Documents\\notes.txt", to="Select files")

drag_file(r"/home/vugia/Downloads/chrome-lin64.tar.gz", to="Select files")
time.sleep(2)
write('glaq4mmn@anonaddy.me', into='email')
time.sleep(2)
write('mymofile6789', into=S('#hiddenMenu > div:nth-child(3) > div:nth-child(1) > div > input'))
time.sleep(2)
write('30', into=S('#hiddenMenu > div:nth-child(3) > div:nth-child(3) > div > input'))
time.sleep(2)
click('Save now!')
time.sleep(5)
# click('Ok')
# x = TextField("Share file").value

# requests.post("https://ntfy.sh/momoin-workupload-backup",
#     data=str(x).encode(encoding='utf-8'))
