.PHONY: install tokens build serve clean

export PERL5LIB := $(CURDIR)/local/lib/perl5

# Install Perl dependencies into ./local (no root needed).
install:
	PERL_MM_USE_DEFAULT=1 PERL_MM_OPT="INSTALL_BASE=$(CURDIR)/local" PERL_MB_OPT="--install_base $(CURDIR)/local" \
		cpan -T Markdown::Perl Template

# Regenerate design-system/tokens.css from tokens.json.
tokens:
	perl design-system/build-tokens.pl

build: tokens
	perl bin/build.pl

# Preview the built site at http://localhost:8000
serve: build
	cd output && python3 -m http.server 8000

clean:
	rm -rf output
