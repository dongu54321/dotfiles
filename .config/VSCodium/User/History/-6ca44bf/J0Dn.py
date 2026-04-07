
webdriver.ChromeOptions()

options = get_default_chrome_options() # this is a below function

options.binary_location = /usr/bin/brave
options.add_argument("--start-maximized")

extension_file_path = os.path.abspath("tests/extensions/webextensions-selenium-example.crx")
options.add_extension(extension_file_path)

driver = webdriver.Chrome(options=options)

def get_default_chrome_options():
    options = webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    return options
