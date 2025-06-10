![chawrt logo](include/logo.png)

chawrt is a variant of the OpenWrt project, focused on providing a custom firmware experience. This guide outlines how to compile chawrt firmware from source.

## Building chawrt Firmware

To build your own chawrt firmware you need a GNU/Linux, BSD or macOS system (case
sensitive filesystem required). Cygwin is unsupported because of the lack of a
case sensitive file system.

### Requirements

You need the following tools to compile chawrt, the package names vary between
distributions. A complete list with distribution specific packages is found in
the [Build System Setup](https://openwrt.org/docs/guide-developer/build-system/install-buildsystem)
documentation.

```
binutils bzip2 diff find flex gawk gcc-6+ getopt grep install libc-dev libz-dev
make4.1+ perl python3.7+ rsync subversion unzip which
```

### Quickstart

1. Run `./scripts/feeds update -a` to obtain all the latest package definitions
   defined in feeds.conf / feeds.conf.default

2. Run `./scripts/feeds install -a` to install symlinks for all obtained
   packages into package/feeds/

3. Run `make menuconfig` to select your preferred configuration for the
   toolchain, target system & firmware packages.

4. Run `make` to build your chawrt firmware. This will download all sources, build the
   cross-compile toolchain and then cross-compile the GNU/Linux kernel & all chosen
   applications for your chawrt target system.

### Related Repositories

chawrt uses the following main repositories for its LuCI interface and packages:

* [LuCI Web Interface](https://github.com/liudf0716/luci): Modern and modular
  interface to control the device via a web browser.

* [chawrt Packages](https://github.com/liudf0716/packages): Main package repository for chawrt.

## License

chawrt is licensed under GPL-2.0
