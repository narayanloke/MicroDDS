
# ============================================================
# MicroDDS - Build System
# ============================================================

PROJECT      := microdds
VERSION      := 0.1.0

CC           := gcc
AR           := ar
ARFLAGS      := rcs

BUILD        ?= release
BUILD_DIR    := build/$(BUILD)
OBJ_DIR      := $(BUILD_DIR)/obj
BIN_DIR      := $(BUILD_DIR)/bin
LIB_DIR      := $(BUILD_DIR)/lib

INCLUDE_DIR  := include
SRC_DIR      := src
TEST_DIR     := tests
EXAMPLE_DIR  := examples

# ------------------------------------------------------------
# Compiler flags
# ------------------------------------------------------------

CSTD         := -std=c11

WARNINGS     := -Wall -Wextra -Wpedantic \
                -Wshadow -Wstrict-prototypes \
                -Wmissing-prototypes

INCLUDES     := -I$(INCLUDE_DIR)

DEFINES      := -D_POSIX_C_SOURCE=200809L \
                -DMICRODDS_VERSION=\"$(VERSION)\"

BASE_CFLAGS  := $(CSTD) $(WARNINGS) $(INCLUDES) $(DEFINES)
THREAD_FLAGS := -pthread

ifeq ($(BUILD),debug)
    CFLAGS := $(BASE_CFLAGS) -O0 -g3 \
              -fsanitize=address,undefined \
              -fno-omit-frame-pointer
    LDFLAGS := -fsanitize=address,undefined
else
    CFLAGS := $(BASE_CFLAGS) -O2 -DNDEBUG
    LDFLAGS :=
endif

CFLAGS  += $(THREAD_FLAGS)
LDFLAGS += $(THREAD_FLAGS)

LDLIBS  :=

# ------------------------------------------------------------
# Source files
# ------------------------------------------------------------

LIB_SOURCES := $(shell find $(SRC_DIR) -type f -name '*.c' 2>/dev/null)

LIB_OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(LIB_SOURCES))

TEST_SOURCES := $(shell find $(TEST_DIR) -type f -name '*.c' 2>/dev/null)

TEST_OBJECTS := $(patsubst $(TEST_DIR)/%.c,$(OBJ_DIR)/tests/%.o,$(TEST_SOURCES))

EXAMPLE_SOURCES := $(wildcard $(EXAMPLE_DIR)/*.c)

EXAMPLE_BINS := $(patsubst $(EXAMPLE_DIR)/%.c,$(BIN_DIR)/%,$(EXAMPLE_SOURCES))

LIBRARY := $(LIB_DIR)/libmicrodds.a
TEST_BIN := $(BIN_DIR)/microdds_tests

# ------------------------------------------------------------
# Default target
# ------------------------------------------------------------

.PHONY: all
all: library examples

# ------------------------------------------------------------
# Build library
# ------------------------------------------------------------

.PHONY: library
library: $(LIBRARY)

$(LIBRARY): $(LIB_OBJECTS)
	@mkdir -p $(LIB_DIR)
	$(AR) $(ARFLAGS) $@ $^

# ------------------------------------------------------------
# Compile source files
# ------------------------------------------------------------

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# ------------------------------------------------------------
# Build examples
# ------------------------------------------------------------

.PHONY: examples
examples: $(EXAMPLE_BINS)

$(BIN_DIR)/%: $(EXAMPLE_DIR)/%.c $(LIBRARY)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $< -L$(LIB_DIR) \
		-lmicrodds $(LDFLAGS) $(LDLIBS) -o $@

# ------------------------------------------------------------
# Build and run tests
# ------------------------------------------------------------

.PHONY: test
test: $(TEST_BIN)
	./$(TEST_BIN)

$(OBJ_DIR)/tests/%.o: $(TEST_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(TEST_BIN): $(TEST_OBJECTS) $(LIBRARY)
	@mkdir -p $(BIN_DIR)
	$(CC) $(TEST_OBJECTS) -L$(LIB_DIR) \
		-lmicrodds $(LDFLAGS) $(LDLIBS) -o $@

# ------------------------------------------------------------
# Build modes
# ------------------------------------------------------------

.PHONY: debug release

debug:
	$(MAKE) BUILD=debug all

release:
	$(MAKE) BUILD=release all

# ------------------------------------------------------------
# Utilities
# ------------------------------------------------------------

.PHONY: clean
clean:
	rm -rf build

.PHONY: info
info:
	@echo "Project : $(PROJECT)"
	@echo "Version : $(VERSION)"
	@echo "Build   : $(BUILD)"
	@echo "Compiler: $(CC)"

# ------------------------------------------------------------
# Header dependencies
# ------------------------------------------------------------

-include $(LIB_OBJECTS:.o=.d)
-include $(TEST_OBJECTS:.o=.d)
