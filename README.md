# dependency

<br/>

## Description

A system agnostic function to have packages installed, updated, or removed.

## Options

- `-i/--install`, install packages. This is the default option.

- `-u/--update`, update or, if not installed, install packages

- `-r/--remove`, uninstall packages.

- `-n/--name`, output the name of a plugin that calls for the installation/update of given packages and as for permission to have them installed/updated.

- `-f/--force [package]`, when uninstalling a package, do so by simply deleating its binary.

- `--p/pip [package]`, describe a package to be handled using `pip`.

- `--N/npm [package]`, describe a package to be handled using `npm`.

- `--P/plugin [package]`, describe a fish plugin to be handled with either `omf` or `fisher`. To install, pass the **address** of its git repository.

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
