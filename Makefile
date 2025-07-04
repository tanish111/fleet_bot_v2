# Makefile for Instruction Manager
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2
TARGET = instruction_manager
SOURCE = instruction_manager.cpp

# Default target
all: $(TARGET)

# Build the instruction manager
$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)

# Clean build artifacts
clean:
	rm -f $(TARGET)

# Install (copy to PATH)
install: $(TARGET)
	cp $(TARGET) /usr/local/bin/

# Make executable and run once for testing
test: $(TARGET)
	chmod +x $(TARGET)
	./$(TARGET) --once

# Make scripts executable
setup:
	chmod +x get_instruction.sh
	chmod +x random_generator.sh
	chmod +x format_checker.sh

# Run the infinite loop version
run: $(TARGET) setup
	./$(TARGET)

.PHONY: all clean install test setup run
