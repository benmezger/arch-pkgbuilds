set shell := ["/bin/bash", "-c", "-eu", "-o", "pipefail"]
PACKAGE_FILE := "PACKAGES"
makepkg_flags := "-f"

arch := "x86_64"
pkgsdir := "../pacman-local"

# Build order:
# 1. build <package>
# 2. pkgcheck <package>
# 3. copy <package>
# 4. manually run ./build-db.sh in $pkgsdir

all:
        @echo "Using {{PACKAGE_FILE}} file"
        just clone
        for pkg in `cat {{PACKAGE_FILE}}`; do \
            just single $pkg; \
        done

single target:
        just makepkg_flags={{makepkg_flags}} build {{target}}
        just pkgcheck {{target}}
        just pkgsdir={{pkgsdir}} copy {{target}}

build target:
        @echo "Building {{target}}"
        cd {{target}} && makepkg -s --noconfirm {{makepkg_flags}}

clean:
        find . -name *.pkg.tar.zst -exec rm -rfv {} \;

pkgcheck target:
        @echo "Checking if there is no new package update"
        # NOTE: this check is for in case we ran makepkg on a git-based package,
        # and that package was updated. In this case, we want to exit so we can
        # manually fix the package
        if git status --porcelain | grep -q {{target}}; then \
              echo "Package was updated, check the new version, commit and rebuild."; \
              git diff {{target}}; \
              exit 1; \
        fi

        if ! ls {{target}} | grep -q pkg.tar.zst ; then \
              echo "No generated PKG found for {{target}}"; \
              exit 1; \
        fi

copy target:
        cp -v {{target}}/*.pkg.tar.zst {{pkgsdir}}/{{arch}}/

check-updates:
        @echo "Using {{PACKAGE_FILE}} file"
        for pkg in `cat {{PACKAGE_FILE}}`; do \
            just makepkg_flags="--nobuild" build $pkg; \
        done

        git diff

clone:
        @echo "Initializing and cloning submodules"
        git submodule update --init --recursive
