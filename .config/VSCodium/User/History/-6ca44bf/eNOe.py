

options = webdriver.chrome.options
options = get_default_chrome_options()
options.binary_location = chrome_bin
options = get_default_chrome_options()


driver = webdriver.Chrome(options=options)