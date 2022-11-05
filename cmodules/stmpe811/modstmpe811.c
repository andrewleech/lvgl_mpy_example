#include <stdint.h>
#include <stdbool.h>

#include "py/runtime.h"
#include "py/mphal.h"
#include "py/binary.h"
#include "py/objarray.h"
#include "lvgl/lvgl.h"
#include "stmpe811.h"

// I2C Interface
STATIC int ts_i2c_address = -1;
STATIC mp_obj_t ts_i2c_obj = mp_const_none;

void IOE_Init(void) {}
void IOE_ITConfig (void) {}

void IOE_Delay(uint32_t delay) {
    mp_hal_delay_ms(delay);
}

void IOE_Write(uint8_t addr, uint8_t reg, uint8_t value) {
    if (ts_i2c_obj == mp_const_none) {
        return;
    }

    mp_obj_array_t buff = {{&mp_type_bytearray}, BYTEARRAY_TYPECODE, 0, 1, &value};
    mp_obj_t dest[5] = {
        NULL,
        NULL,
        MP_OBJ_NEW_SMALL_INT(addr),
        MP_OBJ_NEW_SMALL_INT(reg),
        MP_OBJ_FROM_PTR(&buff)
    };
    mp_load_method(ts_i2c_obj, MP_QSTR_writeto_mem, dest);
    mp_call_method_n_kw(3, 0, dest);
}

uint8_t IOE_Read(uint8_t addr, uint8_t reg) {
    if (ts_i2c_obj == mp_const_none) {
        return 0;
    }

    uint8_t value;
    mp_obj_array_t buff = {{&mp_type_bytearray}, BYTEARRAY_TYPECODE, 0, 1, &value};
    mp_obj_t dest[5] = {
        NULL,
        NULL,
        MP_OBJ_NEW_SMALL_INT(addr),
        MP_OBJ_NEW_SMALL_INT(reg),
        MP_OBJ_FROM_PTR(&buff)
    };
    mp_load_method(ts_i2c_obj, MP_QSTR_readfrom_mem_into, dest);
    mp_call_method_n_kw(3, 0, dest);

    return value;
}

uint16_t IOE_ReadMultiple(uint8_t addr, uint8_t reg, uint8_t *buffer, uint16_t length) {
    if (ts_i2c_obj == mp_const_none) {
        return 0;
    }

    mp_obj_array_t buff = {{&mp_type_bytearray}, BYTEARRAY_TYPECODE, 0, length, buffer};
    mp_obj_t dest[5] = {
        NULL,
        NULL,
        MP_OBJ_NEW_SMALL_INT(addr),
        MP_OBJ_NEW_SMALL_INT(reg),
        MP_OBJ_FROM_PTR(&buff)
    };
    mp_load_method(ts_i2c_obj, MP_QSTR_readfrom_mem_into, dest);
    mp_call_method_n_kw(3, 0, dest);

    return 0;
}


// micropython module
STATIC mp_obj_t mp_ts_init(mp_obj_t i2c_obj, mp_obj_t i2c_address_obj) {

    ts_i2c_address = mp_obj_get_int(i2c_address_obj);
    ts_i2c_obj = i2c_obj;

    stmpe811_Init(ts_i2c_address);
    stmpe811_TS_Start(ts_i2c_address);

    return mp_const_none;
}

STATIC MP_DEFINE_CONST_FUN_OBJ_2(mp_init_obj, mp_ts_init);

STATIC bool touchpad_get_xy(int16_t *x, int16_t *y)
{
	static int32_t _x = 0, _y = 0;
	int16_t xDiff, yDiff, xr, yr;
	uint16_t x_raw, y_raw;;

	bool detected;
	detected = stmpe811_TS_DetectTouch(ts_i2c_address);

	if(!detected) return false;

	stmpe811_TS_GetXY(ts_i2c_address, &x_raw, &y_raw);

	/* Y value first correction */
	y_raw -= 360;

	/* Y value second correction */
	yr = y_raw / 11;

	/* Return y_raw position value */
	// if(yr <= 0) yr = 0;
	// else if (yr > TFT_VER_RES) yr = TFT_VER_RES - 1;

	y_raw = yr;

	/* X value first correction */
	if(x_raw <= 3000) x_raw = 3870 - x_raw;
	else  x_raw = 3800 - x_raw;

	/* X value second correction */
	xr = x_raw / 15;

	/* Return X position value */
	// if(xr <= 0) xr = 0;
	// else if (xr > TFT_HOR_RES) xr = TFT_HOR_RES - 1;

	x_raw = xr;
	xDiff = x_raw > _x? (x_raw - _x): (_x - x_raw);
	yDiff = y_raw > _y? (y_raw - _y): (_y - y_raw);

	if (xDiff + yDiff > 5) {
		_x = x_raw;
		_y = y_raw;
	}

	/* Update the X and Y position */
	*x = _x;
	*y = _y;

	return true;
}

/**
 * Read an input device
 * @param indev_id id of the input device to read
 * @param x put the x coordinate here
 * @param y put the y coordinate here
 * @return true: the device is pressed, false: released
 */
STATIC mp_obj_t mp_ts_read(mp_obj_t indev_drv_obj, mp_obj_t data_obj)
{
    LV_UNUSED(indev_drv_obj);
    lv_indev_data_t *data = MP_OBJ_TO_PTR(data_obj);

    static int16_t last_x = 0;
    static int16_t last_y = 0;

	bool detected;
	int16_t x;
	int16_t y;
	detected = touchpad_get_xy(&x, &y);
	if(detected) {
		data->point.x = x;
		data->point.y = y;
		last_x = data->point.x;
		last_y = data->point.y;

		data->state = LV_INDEV_STATE_PR;
	} else {
		data->point.x = last_x;
		data->point.y = last_y;
		data->state = LV_INDEV_STATE_REL;
	}

    return mp_const_false;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(mp_ts_read_obj, mp_ts_read);


STATIC const mp_rom_map_elem_t stmpe811_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_stmpe811) },
    { MP_ROM_QSTR(MP_QSTR_init), MP_ROM_PTR(&mp_init_obj) },
    { MP_ROM_QSTR(MP_QSTR_ts_read), MP_ROM_PTR(&mp_ts_read_obj)},
};
STATIC MP_DEFINE_CONST_DICT(stmpe811_module_globals, stmpe811_globals_table);

const mp_obj_module_t mp_module_stmpe811 = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&stmpe811_module_globals
};

MP_REGISTER_MODULE(MP_QSTR_stmpe811, mp_module_stmpe811);
