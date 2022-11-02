BOARD ?= STM32F429DISC
PORT ?= stm32

MAKE_OPTIONS := -j$(shell nproc)
PROJECT_BASE :="$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))"
MICROPYTHON_BASE := $(PROJECT_BASE)/lib/micropython

# BOARD_DIR = $(abspath $(BOARD))
BUILD = $(abspath build-$(BOARD))

.PHONY: all
all:
	# $(MAKE) -C $(MICROPYTHON_BASE)/ports/$(PORT) BUILD=$(BUILD) BOARD=$(BOARD) BOARD_DIR=$(BOARD_DIR)
	$(MAKE) -C $(MICROPYTHON_BASE)/ports/$(PORT) $(MAKE_OPTIONS) BUILD=$(BUILD) BOARD=$(BOARD) COPT=-Os MICROPY_FLOAT_IMPL=double DEBUG=1 USER_C_MODULES=$(PROJECT_BASE)/cmodules
	@echo "firmware available at: $(BUILD)/firmware.elf"

.PHONY: clean
clean:
	@echo "Cleaning MicroPython ..."
	rm -rf $(PROJECT_BASE)/build-*
