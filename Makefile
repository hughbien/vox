INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

build: bin/vox
bin/vox:
	shards build --production
	rm -f bin/vox.dwarf

build-static:
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:0.36.1-alpine shards build --production --static
	mv bin/vox bin/vox-linux-amd64

install: build
	cp bin/vox $(INSTALL_BIN)

release: build-static
	$(eval MD5 := $(shell md5sum bin/vox-linux-amd64 | cut -d" " -f1))
	@echo v$(VERSION) $(MD5)
	sed -i "" -E "s/v[0-9]+\.[0-9]+\.[0-9]+/v$(VERSION)/g" README.md
	sed -i "" -E "s/[0-9a-f]{32}/$(MD5)/g" README.md

push:
	git tag v$(VERSION)
	git push --tags
	gh release create -R hughbien/vox -t v$(VERSION) v$(VERSION) ./bin/vox-linux-amd64

spec: test
test:
	crystal spec $(ARGS)

clean:
	rm -rf bin

run:
	crystal run src/cli.cr -- $(ARGS)
