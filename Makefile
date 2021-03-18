INSTALL_BIN ?= /usr/local/bin
VERSION = $(shell cat shard.yml | grep version | sed -e "s/version: //")

build: bin/vox
bin/vox:
	shards build --production
	rm bin/vox.dwarf

build-static:
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:0.36.1-alpine shards build --production --static
	mv bin/vox bin/vox-linux64

install: build
	cp bin/vox $(INSTALL_BIN)

spec: test
test:
	crystal spec $(ARGS)

clean:
	rm -rf bin

run:
	crystal run src/cli.cr -- $(ARGS)
