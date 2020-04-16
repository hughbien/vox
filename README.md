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
    | _site.html
    | 404.md
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
    | all.{{fingerprint}}.css
    | all.{{fingerprint}}.js
    | 404.html
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

* add generator: Makefile, gitignore/nginx/htaccess, fonts, icons, reset css
* spec_helper: root/src/target handling
* specs: cleanup/config/classify/command/db/hooks/blog/list/front-matter/rss/generators/patch
* add remove target dir before generation 
* add target block (error if target already exists on copy/render)
* add -d server mode
* add sitemap
* add rss
* add rss categories
* add rss drip
* add render partial
* add asset encode
* add asset sprite via glue (+ retina)
* add yaml injection tools: db include/read/write, frontmatter include/read/write

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
