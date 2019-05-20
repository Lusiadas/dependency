# dependency

## Description

A system agnostic function to have packages installed, updated, or removed.

## Options

- `-i/--install`, install packages. This is the default option. Packages with different names across distributions can have their alternative names described separated by a slash. i.e. `libgpgme-dev/gpgme-dev`.

- `-u/--update`, update or, if not installed, install packages

- `-r/--remove`, uninstall packages.

- `-n/--name [function]`, output the name of a function that calls for the installation/update of given packages, and ask for permission to have them installed/updated.

- `-f/--force [package]`, when uninstalling a package, do so by simply deleating its binary.

- `--p/pip [package]`, describe a package to be handled using `pip`.

- `--N/npm [package]`, describe a package to be handled using `npm`.

- `--P/plugin [package]`, describe a fish plugin to be handled with either `omf` or `fisher`. To install, pass the **address** of its git repository.

## Disclaimer

> This script has only been tested on Termux and Debian-based operating systems, both of which use the `apt` package manager by default. The commands for verification, installation, updating and uninstallation of other default package managers have been drawn from reference. If you experience problems using this script wih your default package manager, issue reports and pull requests will be most welcome.

---

Ⓐ Made in Anarchy. No wage slaves were economically coerced into the making of this work.