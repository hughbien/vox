# Vox

Vox is a static site generator.

> Daisy Fitzroy hears your voice! Join the Vox Populi!

## Installation

Download the binary from the latest release and place it in your `$PATH`.

Or checkout this repo and run `make build`. The binary should be located in `bin/vox`.

## Usage

Vox looks for a `.vox.yml` or `vox.yml` in the current directory. A basic configuration would be:

```yml
render.pages:
  src: "src/*.md"
  target: "target"
  layout: "src/layout/page.html.ecr"
```

Running `vox` will create a `target` directory with every Markdown page rendered as HTML.

## Development

Use `make` for common tasks:

```
make spec                    # run all tests
make spec ARGS=path/to/spec  # run single test
make build                   # build `bin/vox` binary
make install                 # copy `bin/vox` binary into system bin (using $INSTALL_BIN)
make release                 # build releases for darwin/linux (requires docker)
make clean                   # remove build artifacts and bin directory
make run                     # run vox locally
make run ARGS=-h             # run vox with local arguments
```

## TODO

* add markdown rendering
* add layout rendering via Kilt
* add reading from YAML config
* add dbs: via yaml, all front-matter, db generation
* add front-matter YAML
* add front-matter configs: layout, path (or target_filename)
* add front-matter yaml injection
* add multi-render templates via Kilt
* add asset pipeline: compress, concat, fingerprint
* add base64 encoding assets
* add hooks
* add blog
* add rss
* add drip rss
* add sitemap
* add generator (for common nginx/htaccess/Makefile/gitignore/fonts/icons/etc...)

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
