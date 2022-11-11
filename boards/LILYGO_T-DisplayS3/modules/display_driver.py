import lvgl as lv
from machine import Pin

try:
    import lv_utils
    lv_utils_available = True
except:
    lv_utils_available = False

ORIENT_LANDSCAPE = False
ORIENT_PORTRAIT  = True

class driver:

    def __init__(self,width=420,height=320,orientation=ORIENT_PORTRAIT, asynchronous=False, exception_sink=None, defaultGroup=True):

        if not lv.is_initialized():
            lv.init()

        self.group = lv.group_create()
        if defaultGroup:
            self.group.set_default()

        self.width = width
        self.height = height
        self.orientation = orientation
        self.asynchronous = asynchronous
        self.exception_sink = exception_sink
        self.disp = None
        self.touch = None
        self.type = None
        if not (lv_utils_available and lv_utils.event_loop.is_running()):
            self.init_gui()

    def init_gui_SDL(self):

        import SDL
        SDL.init(w=self.width, h=self.height, auto_refresh=(not lv_utils_available))
        if lv_utils_available:
            self.event_loop = lv_utils.event_loop(refresh_cb = SDL.refresh, asynchronous=self.asynchronous, exception_sink=self.exception_sink)

        # Register SDL display driver.

        disp_buf1 = lv.disp_draw_buf_t()
        buf1_1 = bytearray(self.width*10)
        disp_buf1.init(buf1_1, None, len(buf1_1)//4)
        disp_drv = lv.disp_drv_t()
        disp_drv.init()
        disp_drv.draw_buf = disp_buf1
        disp_drv.flush_cb = SDL.monitor_flush
        disp_drv.hor_res = self.width
        disp_drv.ver_res = self.height
        disp_drv.register()

        # Register SDL mouse driver

        indev_drv = lv.indev_drv_t()
        indev_drv.init()
        indev_drv.type = lv.INDEV_TYPE.POINTER
        indev_drv.read_cb = SDL.mouse_read
        indev_drv.register()

        # Register keyboard driver

        keyboard_drv = lv.indev_drv_t()
        keyboard_drv.init()
        keyboard_drv.type = lv.INDEV_TYPE.KEYPAD
        keyboard_drv.read_cb = SDL.keyboard_read
        self.keyboard = keyboard_drv.register()
        self.keyboard.set_group(self.group)

        self.type = "SDL"
        print("Running the SDL lvgl version")

        self.width=420
        self.height=320

    def init_gui_st77xx(self):

        import st77xx

        spi=machine.SPI(
            1,
            baudrate=24_000_000,
            polarity=0,
            phase=0,
            sck=machine.Pin(18,machine.Pin.OUT),
            mosi=machine.Pin(19,machine.Pin.OUT),
            miso=machine.Pin(20,machine.Pin.IN)
        )
        self.disp=st77xx.St7789(rot=st77xx.ST77XX_INV_LANDSCAPE,res=(240,320),spi=spi,cs=9,dc=8,bl=Pin(38),rst=Pin(5))
        self.disp.set_backlight(100)

        self.height = 320
        self.width = 240

    def init_gui(self):

        # Identify platform and initialize it
        try:
            self.init_gui_st77xx()
            return
        except ImportError:
            pass

        try:
            self.init_gui_SDL()
            return
        except ImportError:
            pass

        raise RuntimeError("Could not find a suitable display driver!")

