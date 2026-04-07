from helium import *
from time import sleep
Config.implicit_wait_secs = 25

import time
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.remote.webdriver import By
import selenium.webdriver.support.expected_conditions as EC  # noqa
from selenium.webdriver.support.wait import WebDriverWait

import undetected_chromedriver as uc

chrome = uc.Chrome()

set_driver(chrome)
start_firefox('https://workupload.com/')
#drag_file(r"C:\\Documents\\notes.txt", to="Select files")

drag_file(r"/home/vugia/arkenfox-userjs-2023-08-17.tar.gz.aa", to="Select files")

write('vuchien166@proton.me', into='email')
write('30', into='storagetime')
click('share now')
click('Ok')
x = TextField("Share file").value

requests.post("https://ntfy.sh/momoin-workupload-backup",
    data=str(x).encode(encoding='utf-8'))
