.PHONY: all clean test help

define NL


endef

VERSION := $(shell cat VERSION)
OUTPUT  := makeself-$(VERSION).run

all: $(OUTPUT)

$(OUTPUT): makeself.sh makeself-header.sh VERSION
	./make-release.sh

clean:
	$(RM) makeself-*.run

test:
	$(foreach f, \
		$(notdir $(sort $(filter-out test/bashunit,$(wildcard test/*)))), \
		cd test; \
		if ! ./$(f); then \
			echo; \
			echo "*** ERROR: Test '$(f)' failed!"; \
			echo; \
			exit 1; \
		fi$(NL))

help:
	$(info Targets: all $(OUTPUT) clean test help)
