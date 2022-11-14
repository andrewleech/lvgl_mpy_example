freeze("$(PORT_DIR)/modules", ("_boot.py", "apa106.py", "flashbdev.py"))
# freeze("$(MPY_DIR)/tools", ("upip.py", "upip_utarfile.py"))
# freeze("$(MPY_DIR)/ports/esp8266/modules", "ntptime.py")
# freeze("$(MPY_DIR)/drivers/dht", "dht.py")
# freeze("$(MPY_DIR)/drivers/onewire")
include("$(MPY_DIR)/extmod/uasyncio/manifest.py")
# include("$(MPY_DIR)/extmod/webrepl/manifest.py")
# include("$(MPY_DIR)/drivers/neopixel/manifest.py")
freeze("modules")

LV_BINDINGS = "$(MPY_DIR)/../../cmodules/lv_binding_micropython"

freeze(f"{LV_BINDINGS}/lib", "lv_utils.py")
freeze(f"{LV_BINDINGS}/driver/generic", ("st77xx.py",))
