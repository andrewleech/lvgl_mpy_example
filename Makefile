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

