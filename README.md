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

* refactor spec_helper: root/src/target handling
* add asset fingerprint for non-css/js
* add configs: ignore render/mustache, css/js/asset minify/fingerprint, target
* add copy unrecognize-able file extensions (dedicated js/css/assets directory required?)
* add yaml db
* finalize yaml variables/scopes
* add clean task
* add hooks: before/after all, before/after/after-fingerprint each
* add blog, lists
* add rss, categories, drip
* add sitemap
* add generator default: Makefile, gitignore
* add generator customize: nginx/htaccess, fonts, icons, reset css
* add render partial
* add asset encode
* add asset sprite (via glue, include retina)
* add yaml injection tools: db, front-matter

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
