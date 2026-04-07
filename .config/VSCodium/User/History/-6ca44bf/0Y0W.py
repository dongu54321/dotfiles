
webdriver.ChromeOptions()

options = get_default_chrome_options() # this is a below function
options.binary_location = /usr/bin/brave
options = get_default_chrome_options()


driver = webdriver.Chrome(options=options)

def get_default_chrome_options():
    options = webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    return options
