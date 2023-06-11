# Archlinux repository

Personal Archlinux package repository.

## Requirements

``` sh
pacman -S base-devel just base-devel git
```

## Building
* Building a single package
    You can build a single package with `just build <package-name>`
* Building a multiple packages
    You can build all enabled packages (See `PACKAGES` file) by running `just all`.
