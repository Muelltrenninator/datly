# Requirements:
# - Dart SDK and Flutter SDK installed and on PATH
# - Make (GNU)

IS_WINDOWS := $(findstring Windows_NT,$(OS))

CLIENT_DIR := packages/datly_client
SERVER_DIR := packages/datly_server
SERVER_PUBLIC := $(SERVER_DIR)/bin/public
CLIENT_BUILD := $(CLIENT_DIR)/build/web

DART := dart
FLUTTER := flutter
DOCKER := docker

ifeq ($(IS_WINDOWS),Windows_NT)
	COPY_CMD := xcopy /E /I /Y
# xcopy expects backslashes; convert when used
	CLIENT_BUILD_WIN := $(subst /,\\,$(CLIENT_BUILD))
	SERVER_PUBLIC_WIN := $(subst /,\\,$(SERVER_PUBLIC))
else
	COPY_CMD := cp -r
endif

.PHONY: all build deps build-client copy-assets clean image

all: build image
build: deps build-client copy-assets
prepare: copy-assets

deps:
	$(DART) pub get

build-client:
	dart run gitbaker
	cd $(CLIENT_DIR) && $(FLUTTER) build web --release --no-web-resources-cdn --csp --wasm

copy-assets:
ifeq ($(IS_WINDOWS),Windows_NT)
	$(COPY_CMD) "$(CLIENT_BUILD_WIN)\*" "$(SERVER_PUBLIC_WIN)"
else
	$(COPY_CMD) "$(CLIENT_BUILD)/" "$(SERVER_PUBLIC)"
endif

# Others:

clean:
	@echo "Cleaning client build and server public assets"
ifeq ($(IS_WINDOWS),Windows_NT)
	if exist "$(CLIENT_BUILD_WIN)" rmdir /S /Q "$(CLIENT_BUILD_WIN)"
	if exist "$(SERVER_PUBLIC_WIN)" rmdir /S /Q "$(SERVER_PUBLIC_WIN)"
else
	rm -rf "$(CLIENT_BUILD)" "$(SERVER_PUBLIC)"
endif

DOCKER_PLATFORMS ?= linux/amd64,linux/arm64
image:
	$(DOCKER) buildx build --pull --platform $(DOCKER_PLATFORMS) \
		-t jhubi/datly:latest \
		-f Dockerfile .
