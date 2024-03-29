# Vox

Vox is a static site generator.

> Daisy Fitzroy hears your voice! Join the Vox Populi!

## Install

**Mac**

```
brew install hughbien/tap/vox
```

If you already have Crystal installed, use `--ignore-dependencies crystal`

**Linux**

Download the latest binary:

```
wget -O /usr/local/bin/vox https://github.com/hughbien/vox/releases/download/v0.1.2/vox-linux-amd64
chmod +x /usr/local/bin/vox
```

MD5 checksum is `9ec28ad7eac3ebc34f9c8ae9dee06f96`.

**From Source**

[Crystal](https://crystal-lang.org) is required. Checkout this repo, run `make` and `make install`:

```
git clone https://github.com/hughbien/vox.git
cd vox
make
make install
```

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
make build                   # build `bin/vox` binary
make build-static             # build static release for Linux
make install                 # copy `bin/vox` binary into system bin (using $INSTALL_BIN)
make spec                    # run all tests
make spec ARGS=path/to/spec  # run single test
make clean                   # remove build artifacts and bin directory
make run                     # run vox locally
make run ARGS=-h             # run vox with local arguments
```

## TODO

* add ability to inline/flatten db/frontmatter vars
* fix scope of page vars, no need to pass huge assets/vars to all other pages
* fix uglifyjs/css to work with asdf/.tools-versions 
* fix output errors and stop build on uglifyjs/css syntax errors
* fix links/next/prev yaml for pages missing frontmatter
* add icon system: css-generator + static-fill, on-page + dynamic-fill
* add terser (sub-uglifyjs) for ES6
* fix rss: reversed, limits, timezone (via config)
* update prints to reference full path (reconsider _ext formats)
* add list/matcher apply to frontmatter
* add server: custom port, target regeneration
* add generator (allow customizing): Makefile, gitignore, nginx-config/htaccess, fonts, icons, reset-css
* spec_helper: root/src/target setup/teardown
* specs: cleanup/config/classify/command/db/hooks/list/front-matter/rss/generators/patch
* add remove target dir at start, target blocking on already existing files for copy/render
* add rss: via-lists, categories
* add sitemap
* add yaml tools for db/frontmatter: include, read, write
* add bundling support: typescript, babel, scss
* add cache, only regenerate pages that update
* fix `excludes`/`render_excludes` for bundle files (js/css/etc...) to keep curly brackets
* fix large asset size causes longer render time
* fix speed up render time as fast as possible

## License

Copyright 2021 Hugh Bien.

Released under BSD License, see LICENSE for details.
