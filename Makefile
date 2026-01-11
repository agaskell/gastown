.PHONY: build install install-go clean test generate

BINARY := gt
BUILD_DIR := .

# Get version info for ldflags
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Determine GOPATH bin directory
GOBIN := $(shell go env GOPATH)/bin

LDFLAGS := -X github.com/steveyegge/gastown/internal/cmd.Version=$(VERSION) \
           -X github.com/steveyegge/gastown/internal/cmd.Commit=$(COMMIT) \
           -X github.com/steveyegge/gastown/internal/cmd.BuildTime=$(BUILD_TIME)

generate:
	go generate ./...

build: generate
	go build -ldflags "$(LDFLAGS)" -o $(BUILD_DIR)/$(BINARY) ./cmd/gt
ifeq ($(shell uname),Darwin)
	@codesign -s - -f $(BUILD_DIR)/$(BINARY) 2>/dev/null || true
	@echo "Signed $(BINARY) for macOS"
endif

# Install to ~/.local/bin (requires ~/.local/bin in PATH)
install: build
	@mkdir -p ~/.local/bin
	cp $(BUILD_DIR)/$(BINARY) ~/.local/bin/$(BINARY)
	@echo "Installed to ~/.local/bin/$(BINARY)"
	@echo "Ensure ~/.local/bin is in your PATH"

# Install to GOPATH/bin (same location as 'go install')
install-go: build
	cp $(BUILD_DIR)/$(BINARY) $(GOBIN)/$(BINARY)
	@echo "Installed to $(GOBIN)/$(BINARY)"

clean:
	rm -f $(BUILD_DIR)/$(BINARY)

test:
	go test ./...
