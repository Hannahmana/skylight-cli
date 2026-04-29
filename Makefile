# skylight-cli Makefile
# Usage: make <target>

.PHONY: all build release clean install uninstall test lint help

# Configuration
PREFIX ?= /usr/local
BINARY_NAME = skylight
BUILD_DIR = .build
RELEASE_BINARY = $(BUILD_DIR)/release/$(BINARY_NAME)
DEBUG_BINARY = $(BUILD_DIR)/debug/$(BINARY_NAME)

# Default target
all: build

# Build debug version
build:
	@echo "Building debug..."
	swift build
	@echo "Done: $(DEBUG_BINARY)"

# Build release version
release:
	@echo "Building release..."
	swift build -c release
	@echo "Done: $(RELEASE_BINARY)"

# Clean build artifacts
clean:
	@echo "Cleaning..."
	swift package clean
	rm -rf $(BUILD_DIR)
	@echo "Done"

# Install to PREFIX/bin (requires sudo for /usr/local)
install: release
	@echo "Installing to $(PREFIX)/bin..."
	install -d $(PREFIX)/bin
	install -m 755 $(RELEASE_BINARY) $(PREFIX)/bin/$(BINARY_NAME)
	@echo "Done: $(PREFIX)/bin/$(BINARY_NAME)"

# Uninstall from PREFIX/bin
uninstall:
	@echo "Uninstalling from $(PREFIX)/bin..."
	rm -f $(PREFIX)/bin/$(BINARY_NAME)
	@echo "Done"

# Run smoke tests
test: release
	@echo "Running smoke tests..."
	@./scripts/smoke-test.sh
	@echo "Done"

# Run doctor checks
doctor:
	@echo "Running diagnostics..."
	@./scripts/doctor.sh

# Check code style (basic)
lint:
	@echo "Checking for common issues..."
	@! grep -r "print(" Sources/ --include="*.swift" | grep -v "// print" | grep -v Output || echo "Warning: Found raw print() calls"
	@! grep -r "fatalError" Sources/ --include="*.swift" || echo "Warning: Found fatalError calls"
	@echo "Lint complete"

# Show help
help:
	@echo "skylight-cli Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  build    - Build debug version"
	@echo "  release  - Build release version"
	@echo "  clean    - Remove build artifacts"
	@echo "  install  - Install to $(PREFIX)/bin"
	@echo "  uninstall- Remove from $(PREFIX)/bin"
	@echo "  test     - Run smoke tests"
	@echo "  doctor   - Run diagnostic checks"
	@echo "  lint     - Check for common issues"
	@echo "  help     - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX   - Installation prefix (default: /usr/local)"
