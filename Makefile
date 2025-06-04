# Directories
SRC_DIR := src
BUILD_DIR := build
BIN_DIR := bin

# Files
BOOT_SRC := $(SRC_DIR)/boot.asm
OUTPUT := $(BIN_DIR)/ifnos.bin
IMG := $(BUILD_DIR)/floppy.img

# Constants
FLOPPY_SECTORS := 2880  # 1.44MB floppy = 2880 sectors * 512 bytes

# Tools
ASM := nasm
ASM_FLAGS := -f bin
QEMU := qemu-system-i386

# Default target
all: $(IMG)

# Assemble the bootloader
$(OUTPUT): $(BOOT_SRC) | $(BIN_DIR)
	$(ASM) $(ASM_FLAGS) $< -o $@

# Create floppy image and write bootloader to it
$(IMG): $(OUTPUT) | $(BUILD_DIR)
	dd if=/dev/zero of=$@ bs=512 count=$(FLOPPY_SECTORS)
	dd if=$(OUTPUT) of=$@ conv=notrunc

# Run IfnOS in QEMU (safe and proper command)
run: $(IMG)
	$(QEMU) \
		-drive file=$(IMG),format=raw,if=floppy \
		-boot a \
		-serial stdio

# Ensure output directories exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build output
clean:
	rm -rf $(BIN_DIR)/* $(BUILD_DIR)/*

.PHONY: all clean run
