INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

spec: test
test:
	crystal spec $(ARGS)

build: bin/vox
bin/vox:
	shards build --production
	rm bin/vox.dwarf

release: build
	mv bin/vox bin/vox-darwin64-$(VERSION)
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:latest-alpine shards build --production --static
	mv bin/vox bin/vox-linux64-$(VERSION)

install: build
	cp bin/vox $(INSTALL_BIN)

clean:
	rm -rf bin

run:
	crystal run src/cli.cr -- $(ARGS)
