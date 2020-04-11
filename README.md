# Vox

Vox is a static site generator.

> Daisy Fitzroy hears your voice! Join the Vox Populi!

## Installation

Download the binary from the latest release and place it in your `$PATH`.

Or checkout this repo and run `make build`. The binary should be located in `bin/vox`.

## Usage

A default directory sturcture looks like this:

```
root
| src/
    | assets/
        | hello_world.jpg
    | css/
        | reset.css
        | styles.css
    | js/
        | library.js
        | script.js
    | layouts/
        | site.html
    | 404.md
    | about.md
    | contact.md
    | index.md
```

Running `vox` will generate a target directory with:

* fingerprinted assets
* minified and fingerprinted js/css
* rendered HTML

```
root
| src/...
| target/
    | assets/
        | hello_world.{{fingerprint}}.jpg
    | css/
        | all.{{fingerprint}}.css
    | js/
        | all.{{fingerprint}}.js
    | 404.html
    | about.html
    | contact.html
    | index.html
```

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

* add content html rendering w/ mustache
* add content markdown rendering w/ mustache
* add partials rendering
* add asset pipeline: compress, concat, fingerprint
* add reading from YAML config
* add reading from YAML db (db <- layout front matter <- page front matter)
* add front-matter YAML (eg layout, path, render engine, etc...)
* add yaml injection: db, front-matter
* add configs: ignore, css/js bundling
* add base64 encoding assets
* add clean task
* add hooks
* add blog
* add lists
* add rss
* add rss categories
* add rss drip
* add sitemap
* add generator (for common nginx/htaccess/Makefile/gitignore/fonts/icons/etc...)

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
