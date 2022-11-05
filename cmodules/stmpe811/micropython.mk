STMPE811_DIR := $(USERMOD_DIR)

# CFLAGS_USERMOD += $(LV_CFLAGS) $(INC)

# CFLAGS_USERMOD += -Wno-unused-function

# Add all C files to SRC_USERMOD.
SRC_USERMOD += \
  $(STMPE811_DIR)/stmpe811.c \
  $(STMPE811_DIR)/modstmpe811.c \


# We can add our module folder to include paths if needed
# This is not actually needed in this example.
# CFLAGS_USERMOD += -I$(EXAMPLE_MOD_DIR)
# CEXAMPLE_MOD_DIR := $(USERMOD_DIR)
