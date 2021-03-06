GO_MD2MAN ?= /usr/bin/go-md2man
PREFIX ?= $(DESTDIR)/usr
SYSCONFDIR ?= $(DESTDIR)/etc/sysconfig
PYTHON := $(shell { command -v python3 || command -v python; } 2>/dev/null)
%.PYTHON: %

export PYTHON ?= /usr/bin/python

.PHONY: all
all: python-build docs

.PHONY: python-build
python-build:
	$(PYTHON) setup.py build

MANPAGES_MD = $(wildcard docs/*.md)

docs/%.1: docs/%.1.md
	$(GO_MD2MAN) -in $< -out $@.tmp && touch $@.tmp && mv $@.tmp $@

.PHONY: docs
docs: $(MANPAGES_MD:%.md=%)

.PHONY: install-only
install-only:
	$(PYTHON) setup.py install  --install-scripts usr/libexec `test -n "$(DESTDIR)" && echo --root $(DESTDIR)`
	install -d $(PREFIX)/share/man/man1
	install -m 644 $(basename $(MANPAGES_MD)) $(PREFIX)/share/man/man1

.PHONY: install
install: all install-only

.PHONY: clean
clean:
	$(PYTHON) setup.py clean
	-rm -rf dist build *~ \#* *pyc .#* docs/*.1

.PHONY: test 


test:
	TEST=1 bats test/test.bats


