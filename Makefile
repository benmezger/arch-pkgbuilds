ARCH=x86_64
ARCH_REPO=${HOME}/workspace/pacman-local
ARCH_DB=${ARCH_REPO}/${ARCH}/sedspkgs

.NOTPARALLEL:
.PHONY: all
all: info  build-all copy-all update-db

info:
	@echo "-> Arch repository: ${ARCH_REPO}"
	@echo "-> Order: build-all copy-all update-db"

build-all:
	python build.py

copy-all: */
	find $^ -name \*.pkg.tar.zst -exec cp -v {} ${ARCH_REPO}/${ARCH} \;

update-db:
	rm -v ${ARCH_DB}*
	$(MAKE) copy-all
	repo-add -n -R ${ARCH_DB}.db.tar.gz ${ARCH_REPO}/${ARCH}/*.pkg.tar.zst

	@echo "-> Removing symlinks"
	rm ${ARCH_DB}.db
	rm ${ARCH_DB}.files

	@echo "-> Renaming tar.gz files without extension"
	mv ${ARCH_DB}.db.tar.gz ${ARCH_DB}.db
	mv ${ARCH_DB}.files.tar.gz ${ARCH_DB}.files

