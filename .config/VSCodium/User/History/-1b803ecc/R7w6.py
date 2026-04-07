from helium import *
from time import sleep
Config.implicit_wait_secs = 25

start_firefox('https://workupload.com/')
#drag_file(r"C:\\Documents\\notes.txt", to="Select files")

drag_file(r"/home/vugia/arkenfox-userjs-2023-08-17.tar.gz.aa", to="Select files")

write('vuchien166@proton.me', into='email')
write('30', into='storagetime')
click('share now')