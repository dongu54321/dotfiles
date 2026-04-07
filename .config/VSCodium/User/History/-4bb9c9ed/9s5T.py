from selenium_helper import SeleniumHelper
from time import sleep
from selenium.webdriver import FirefoxOptions
from selenium.webdriver import FirefoxProfile

# from pyvirtualdisplay import Display

profile = FirefoxProfile()
options = FirefoxOptions()
options.headless = False
start_firefox(options=options)