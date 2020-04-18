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

* add rss limits
* add config: timzone (for rss)
* add files (shortcut for fingerprints)
* add either matcher or list apply frontmatter, eg blog/* has different layout or property "selected: blog"
* add server: custom port, target regeneration
* add generator: Makefile, gitignore, nginx-config, htaccess, fonts, icons, reset-css
* spec_helper: root/src/target setup/teardown
* specs: cleanup/config/classify/command/db/hooks/list/front-matter/rss/generators/patch
* add remove target dir at start, target blocking on already existing files for copy/render
* add rss: via-lists, categories, drip
* add trailing slash as config
* add sitemap
* add render partial
* add asset encode, spriting (via glue/retina)
* add yaml injection tools: db include/read/write, frontmatter include/read/write

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
