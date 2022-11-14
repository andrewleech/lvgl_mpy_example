BOARD ?= STM32F429DISC
PORT ?= stm32

MAKE_OPTIONS := -j$(shell nproc)
PROJECT_BASE :="$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))"
MICROPYTHON_BASE := $(PROJECT_BASE)/lib/micropython

BOARD_DIR = $(abspath boards/$(BOARD))
BUILD = $(abspath build-$(BOARD))

.PHONY: all
all:
	$(MAKE) -C $(MICROPYTHON_BASE)/ports/$(PORT) $(MAKE_OPTIONS) BUILD=$(BUILD) BOARD=$(BOARD) BOARD_DIR=$(BOARD_DIR) COPT=-Os
	@echo "firmware available at: $(BUILD)/firmware.elf"

.PHONY: clean
clean:
	@echo "Cleaning MicroPython ..."
	rm -rf $(PROJECT_BASE)/build-*

.PHONY: unix
unix:
	$(MAKE) -C $(MICROPYTHON_BASE)/ports/unix $(MAKE_OPTIONS) VARIANT=libvgl VARIANT_DIR=$(PROJECT_BASE)/unix submodules
	$(MAKE) -C $(MICROPYTHON_BASE)/ports/unix $(MAKE_OPTIONS) \
	    BUILD=$(PROJECT_BASE)/build-unix DEBUG=1\
		VARIANT=libvgl VARIANT_DIR=$(PROJECT_BASE)/unix

.PHONY: esp
esp:
	@docker run -ti --rm -v $$(pwd):/code -w /code espressif/idf:v4.4.3 bash -c '\
	git config --global --add safe.directory "*" &&\
	make -C lib/micropython/ports/esp32 submodules &&\
	pushd boards/LILYGO_T-DisplayS3 &&\
	idf.py -D MICROPY_BOARD="LILYGO_T-DisplayS3" build &&\
	popd &&\
	python3 lib/micropython/ports/esp32/makeimg.py \
		boards/LILYGO_T-DisplayS3/build/sdkconfig \
		boards/LILYGO_T-DisplayS3/build/bootloader/bootloader.bin \
		boards/LILYGO_T-DisplayS3/build/partition_table/partition-table.bin \
		boards/LILYGO_T-DisplayS3/build/micropython.bin \
		boards/LILYGO_T-DisplayS3/build/firmware.bin \
		boards/LILYGO_T-DisplayS3/build/micropython.uf2\
	'

.PHONY: esp-deploy
make esp-deploy:
	esptool.py --chip esp32s3 --port /dev/ttyACM0 write_flash -z 0 boards/LILYGO_T-DisplayS3/build/firmware.bin


rp2:
	make -j $(nproc) -C lib/micropython/ports/rp2 submodules
	make -j $(nproc) -C lib/micropython/ports/rp2 BOARD=PICO USER_C_MODULES=../../../../cmodules/lv_binding_micropython/bindings.cmake


esp32:
	@docker run -ti --rm -v $$(pwd):/code -w /code espressif/idf:v4.4.3 bash -c '\
	git config --global --add safe.directory "*" &&\
	make -C lib/micropython/ports/esp32 submodules &&\
	make -C lib/micropython/ports/esp32 USER_C_MODULES=/code/cmodules/lv_binding_micropython/bindings.cmake \
	'
