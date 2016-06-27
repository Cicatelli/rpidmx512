ARMGNU ?= arm-none-eabi

INCLUDES := -I./include
INCLUDES += $(addprefix -I,$(EXTRA_INCLUDES))

DEFINES := $(addprefix -D,$(DEFINES))

COPS_COMMON = -DBARE_METAL $(DEFINES)
COPS_COMMON += $(INCLUDES)
COPS_COMMON += -Wall -Werror -O3 -nostartfiles -ffreestanding -mhard-float -mfloat-abi=hard  

COPS = -mfpu=vfp -march=armv6zk -mtune=arm1176jzf-s -mcpu=arm1176jzf-s
COPS += -DRPI1
COPS += $(COPS_COMMON)

COPS7 = -mfpu=vfpv4 -march=armv7-a -mtune=cortex-a7 # NEON is not enabled in vectors.s
COPS7 += -DRPI2
COPS7 += $(COPS_COMMON)

COPS8 = -mfpu=fp-armv8 -march=armv8-a -mtune=cortex-a53 # NEON is not enabled in vectors.s
COPS8 += -DRPI3
COPS8 += $(COPS_COMMON)

SOURCE = ./src

CURR_DIR := $(notdir $(patsubst %/,%,$(CURDIR)))
LIB_NAME := $(patsubst lib-%,%,$(CURR_DIR))

BUILD = build/
BUILD7 = build7/
BUILD8 = build8/

OBJECTS := $(patsubst $(SOURCE)/%.c,$(BUILD)%.o,$(wildcard $(SOURCE)/*.c)) 
OBJECTS7 := $(patsubst $(SOURCE)/%.c,$(BUILD7)%.o,$(wildcard $(SOURCE)/*.c))
OBJECTS8 := $(patsubst $(SOURCE)/%.c,$(BUILD8)%.o,$(wildcard $(SOURCE)/*.c))

TARGET = lib/lib$(LIB_NAME).a 
TARGET7 = lib7/lib$(LIB_NAME).a
TARGET8 = lib8/lib$(LIB_NAME).a

LIST = lib.list
LIST7 = lib7.list
LIST8 = lib8.list

all : builddirs $(TARGET) $(TARGET7)  $(TARGET8)

.PHONY: clean builddirs

builddirs:
	@mkdir -p build build7 build8 lib lib7 lib8

clean :
	rm -f $(BUILD)*.o
	rm -f $(BUILD7)*.o
	rm -f $(BUILD8)*.o
	rm -f $(TARGET)
	rm -f $(TARGET7)
	rm -f $(TARGET8)	
	rm -f $(LIST)
	rm -f $(LIST7)
	rm -f $(LIST8)	

# ARM v6

$(BUILD)%.o: $(SOURCE)/%.c
	$(ARMGNU)-gcc $(COPS) $< -c -o $@	

$(TARGET): Makefile $(OBJECTS)
	$(ARMGNU)-ar -r $(TARGET) $(OBJECTS) 
	$(ARMGNU)-objdump -D $(TARGET) > $(LIST)
	
# ARM v7	
	
$(BUILD7)%.o: $(SOURCE)/%.c
	$(ARMGNU)-gcc $(COPS7) $< -c -o $@	

$(TARGET7): Makefile $(OBJECTS7)
	$(ARMGNU)-ar -r $(TARGET7) $(OBJECTS7) 
	$(ARMGNU)-objdump -D $(TARGET7) > $(LIST7)
	
# ARM v8	

$(BUILD8)%.o: $(SOURCE)/%.c
	$(ARMGNU)-gcc $(COPS8) $< -c -o $@	

$(TARGET8): Makefile $(OBJECTS8)
	$(ARMGNU)-ar -r $(TARGET8) $(OBJECTS8) 
	$(ARMGNU)-objdump -D $(TARGET8) > $(LIST8)	

	