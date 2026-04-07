
#from random import randint
# from concurrent.futures import ThreadPoolExecutor
# import os
# from pathlib import Path
from selenium_helper import SeleniumHelper
from time import sleep

driver = SeleniumHelper()
driver.loadPage("https://192.168.1.1/")
print('Filling Login.... ')
driver.waitAndWrite("#txt_Username","admin",20)
driver.waitAndWrite("#txt_Password","HWTCC921AEA7",20)
driver.waitAndClick('#button')

driver.waitAndClick('#Cmbutton') #Advanced Setup

driver.waitAndClick('#headerTab > ul > li:nth-child(4) > div.tabBtnCenter') #ipv6

driver.waitAndClick('#nav > ul > li:nth-child(7) > div') #portmapping

# driver.waitAndClick('#portMappingInst_rml0',10) #container

driver.clickXpath('//*[@id="portMappingInst_0_1"]')

driver.clickSelector('#portMappingInst_record_0')

driver.clickId("portMappingInst_record_0")
driver.clickJavascript('#portMappingInst_record_0')
driver.clickName("Container")
print('read ipv6 files')
with open(r'ip.txt', 'r') as f:
    ip6 = f.readlines()
sleep(5)
print('Filling IPv6: ',ip6[0])

try:
    driver.waitAndWrite('#InternalClient', ip6[0])
except:
	sleep(7)
    driver.waitAndWrite('#InternalClient', ip6[0])

driver.waitAndClick('#btnApply_ex')
sleep(7)
driver.waitAndClick('#headerLogoutText')

sleep(2)

driver.close()
