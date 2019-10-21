.PHONY: all test

define NL


endef

all:

test:
	cd test && git submodule update --init --recursive
	$(foreach f, \
		$(notdir $(filter-out test/bashunit,$(wildcard test/*))), \
		cd test; \
		if ! ./$(f); then \
			echo; \
			echo "*** ERROR: Test '$(f)' failed!"; \
			echo; \
			exit 1; \
		fi$(NL))
