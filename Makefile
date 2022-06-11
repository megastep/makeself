.PHONY: all clean test help

VERSION := $(shell cat VERSION)
OUTPUT  := makeself-$(VERSION).run

all: $(OUTPUT)

$(OUTPUT): makeself.sh makeself-header.sh VERSION
	./make-release.sh

clean:
	$(RM) makeself-*.run

test:
	./test/run-tests.sh

help:
	$(info Targets: all $(OUTPUT) clean test help)
