all: serve

.PHONY: publish
publish:
	hugo --minify

.PHONY: clean
clean:
	find build/leroyvn.github.io -not -name ".git" -delete

.PHONY: serve
serve:
	hugo serve
