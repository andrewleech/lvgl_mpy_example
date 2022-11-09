LV_BINDINGS = "$(MPY_DIR)/../../cmodules/lv_binding_micropython"

include("$(MPY_DIR)/extmod/uasyncio/manifest.py")

freeze(f"{LV_BINDINGS}/lib", "lv_utils.py")
freeze(f"{LV_BINDINGS}/driver/generic", ("ili9xxx.py", "st77xx.py"))

freeze(f".", "display_driver.py")
