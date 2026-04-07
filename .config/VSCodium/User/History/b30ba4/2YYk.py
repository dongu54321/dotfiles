from helium import *
from time import sleep
from selenium.webdriver import FirefoxOptions
from selenium.webdriver import FirefoxProfile
from pyvirtualdisplay import Display

# Config.implicit_wait_secs = 25

def try_click(ele):
    for i in range(0, 20):
        try:
            click(ele)
            #things I need to do
        except ValueError:
            print("Try #{} failed with ValueError: Sleeping for 2 secs before next try:".format(i))
            time.sleep(2)
            continue
        break

with Display(visible=0, size=(1600, 900)) as display:
    profile = FirefoxProfile()
    options = FirefoxOptions()
    options.headless = False
    start_firefox(options=options)
    go_to('http://192.168.1.1')
    sleep(3)
    print('Filling Login.... ')
    write('admin', into='Account')
    sleep(1)
    write('h33A$2gvj2gr4U7avic9MQGF849r', into='Password')
    sleep(1)
    try_click(Button("Login"))
    print('Login.... ')
    sleep(5)

    print('Click Advanced Setup')
    try_click(Button("Advanced Setup"))
    sleep(7)
    print('click IPv6')
    try_click('IPv6')

    sleep(2)
    print('Port Mapping')
    try_click('Port Mapping Configuration')

    sleep(10)
        except ValueError:
            print("Try #{} failed with ValueError: Sleeping for 2 secs before next try:".format(i))
            time.sleep(2)
            continue
    print('click momo1_Yuno......')
    # try_click('momo1_Yuno......')
    # driver = helium.get_driver()
    # iframe = driver.find_element_by_xpath("/html/body/div/div[2]/div[2]/div[2]/iframe")
    # driver.switch_to.frame(iframe)

    for i in range(0, 20):
        try:
            click(Text('momo1_Yuno......'))
            #click(S('//*[@id="portMappingInst_rml1"]'))
            # click(S('#portMappingInst_rml1'))
        except ValueError:
            print("Try #{} failed with ValueError: Sleeping for 2 secs before next try:".format(i))
            time.sleep(2)
            continue
        break

    print('read ipv6 files')
    with open(r'ip.txt', 'r') as f:
        ip6 = f.readlines()
    print('Filling IPv6: ',ip6[0])
    sleep(1)

    try:
        write(ip6[0], into =S('#InternalClient'))
    except:
        sleep(5)
        write(ip6[0], into =S('#InternalClient'))

    sleep(1)
    print('click Apply button...')

    press(PAGE_DOWN)
    sleep(1)
    press(PAGE_DOWN)
    sleep(1)
    press(PAGE_DOWN)
    sleep(1)
    press(PAGE_DOWN)
    sleep(1)
    #try_click(Button("Apply"))
    try_click(S('#btnApply_ex'))
    sleep(15)
    try_click('Logout')
    sleep(3)
    kill_browser()