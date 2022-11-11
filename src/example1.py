# init

import usys as sys
sys.path.append('') # See: https://github.com/micropython/micropython/issues/6419

import lvgl as lv
import lv_utils
from display_driver import driver

lv.init()
print("lv_init")


if not lv_utils.event_loop.is_running():
    drv = driver()

# Image data

try:
    with open('/flash/blue_flower_32.bin','rb') as f:
        img_data = f.read()

except OSError:
    with open('./blue_flower_32.bin','rb') as f:
        img_data = f.read()


# Pixel format: Fix 0xFF: 8 bit, Red: 8 bit, Green: 8 bit, Blue: 8 bit

# Create a screen with a draggable image

scr = lv.obj()
img = lv.img(scr)
img.align(lv.ALIGN.CENTER, 0, 0)
img_dsc = lv.img_dsc_t(
    {
        "header": {"always_zero": 0, "w": 100, "h": 75, "cf": lv.img.CF.TRUE_COLOR},
        "data_size": len(img_data),
        "data": img_data,
    }
)

img.set_src(img_dsc)
# img.set_drag(True)

# Load the screen and display image

lv.scr_load(scr)
