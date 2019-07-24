# This Makefile is for building the site locally before pushing to
# Github Pages.

# PREREQS:
#   gem install jekyll bundler
#   bundle install


serve:
	bundle exec jekyll serve --no-watch --config _config.yml

.PHONY: serve
