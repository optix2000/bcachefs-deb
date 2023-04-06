all: tools kernel

.PHONY: tools
tools:
	git clone https://github.com/koverstreet/bcachefs-tools.git
	# Patch debian folder from Debian unstable
	rm -r bcachefs-tools/debian
	cp -r tools/debian bcachefs-tools
	# Build
	cd bcachefs-tools && EMAIL=gh@automated.builds dch -v $$(git describe --tags|cut -c2-) -D unstable "Automated build"
	cd bcachefs-tools && make deb

.PHONY: kernel
kernel:
	git clone https://github.com/koverstreet/bcachefs.git --depth=1
	# Hack to get the config from normal kernel
	xz -d -c /usr/src/linux-config-*/config.amd64_none_amd64.xz > bcachefs/.config
	# Build w/ ACLs
	cd bcachefs && scripts/config --module BCACHEFS_FS && scripts/config --enable BCACHEFS_POSIX_ACL && make olddefconfig && make bindeb-pkg -j 2 EXTRAVERSION=-$$(git rev-parse --short HEAD) LOCALVERSION=
