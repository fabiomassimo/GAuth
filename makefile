CARTHAGE := $(shell command -v carthage)

setup:
ifeq ("$(CARTHAGE)","")
	$(error ${\n}Carthage is not installed.${\n}See https://github.com/Carthage/Carthage for install instructions)
endif
	carthage bootstrap --platform iOS --no-use-binaries

define \n


endef