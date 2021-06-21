all: server

.PHONY: publish
publish:
	hugo --minify

.PHONY: clean
clean:
	find build/leroyvn.github.io -not -name ".git" -delete

.PHONY: server
server:
	hugo server --i18n-warnings -DF -b http://localhost/
