from selenium_helper import SeleniumHelper
from time import sleep
from selenium.webdriver import FirefoxOptions
from selenium.webdriver import FirefoxProfile

# from pyvirtualdisplay import Display

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
        .replace("A.I", "Ây Ai")

    )
    return text