NAME := utils

BUILD := $(CURDIR)/build
DIST  := $(CURDIR)/dist

SYSTEM  != python -c 'import platform; print(platform.system().lower())'
MACHINE != python -c 'import platform; print(platform.machine().lower())'
ifeq ($(SYSTEM), windows)
  EXE := .exe
else
  EXE :=
endif
DIST_EXE := $(DIST)/$(NAME)-$(SYSTEM)-$(MACHINE)$(EXE)

all:

clean:
	@ $(RM) --recursive --verbose $(BUILD)
	@ $(RM) --recursive --verbose $(DIST)
	@ find $(CURDIR) -type d -name '__pycache__' -exec $(RM) --recursive --verbose '{}' +
	@ find $(CURDIR) -type f -name '*.spec'      -exec $(RM) --verbose '{}' +

dist: $(DIST_EXE)

pretty: black prettier

setup:
	conda install --yes libpython-static
	conda install --channel=conda-forge --yes ccache
	poetry install

#####################
# Auxiliary Targets #
#####################

$(DIST_EXE): $(CURDIR)/main.py
ifneq ($(SYSTEM), windows)
	python -m nuitka --standalone --onefile --output-filename=$(@F) --output-dir=$(@D) --remove-output  $<
else
	pyinstaller --distpath=$(DIST) --workpath=$(BUILD) --onefile --name=$(NAME)-$(SYSTEM)-$(MACHINE) $<
endif

black:
	isort --profile=black $(CURDIR)
	black $(CURDIR)

prettier: $(CURDIR)/.gitignore
	prettier --write --ignore-path=$< $(CURDIR)
