# dependency

> *A plugin for [Oh My Fish](https://www.github.com/oh-my-fish/oh-my-fish).*

[![GPL License](https://img.shields.io/badge/license-GPL-blue.svg?longCache=true&style=flat-square)](/LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0-blue.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-blue.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

## Description

A plugin to install or remove packages that is system agnostic. It's meant for use on scripts.

## Options

- `-i/--install`, install packages. This is the default option.

- `-n/--name`, when installing packages, output the name of the plugin that requires such dependencies to be installed.

- `-u/--uninstall`, uninstall packages.

- `-f/--force [package]`, when uninstalling a package, do so by simply deleating its binary.

- `--pip [package]`, describe a package to be handled using `pip`.

- `--pip3 [package]`, describe a package to be handled using `pip3`.

- `--npm [package]`, describe a package to be handled using `npm`.

- `--plugin [package]`, describe a fish plugin to be handled with either `omf` or `fisher` by passing the **full address** of its git repository.

## Install

Either with omf

```fish
$ omf install dependency
```

or [fisherman](https://github.com/fisherman/fisherman)

```fish
fisher gitlab.com/lusiadas/dependency
```

---

Ⓐ Made in Anarchy. No wage slaves were economically coerced into the making of this work.
