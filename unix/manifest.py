include("$(PORT_DIR)/variants/manifest.py")

include("$(MPY_DIR)/extmod/uasyncio")


LV_BINDINGS = "$(MPY_DIR)/../../cmodules/lv_binding_micropython"
freeze(f"{LV_BINDINGS}/lib", (
    "lv_utils.py",
    "fs_driver.py"
))
freeze(f"{LV_BINDINGS}/driver/linux", ("evdev.py", "lv_timer.py"))

freeze(f".", "display_driver.py")
