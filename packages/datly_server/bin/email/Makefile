.DEFAULT_GOAL := generate

IS_WINDOWS := $(findstring Windows_NT,$(OS))
.PHONY: extract gather generate

extract:
	dart run intl_translation:extract_to_arb --output-dir=l10n --locale en email.dart

gather:
ifeq ($(IS_WINDOWS),Windows_NT)
	cd l10n && dir /b /a:-d | findstr /v "\.txt$\" > locales.txt
else
	cd l10n && (ls | grep -Ev '\.txt$\') > locales.txt
endif

generate: gather
	dart run intl_translation:generate_from_arb email.dart --translations-list-file l10n/locales.txt
