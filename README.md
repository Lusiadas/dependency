# dependency

A system agnostic function to have dependencies be installed or removed.

## Options

- `-r/--remove`, uninstall packages (instead of installing them).

- `-n/--name [function]`, output the name of a function, and ask for permission to have its dependencies installed.

- `-f/--force [package]`, when uninstalling a package, do so by simply deleating its executable file.

- `--p/pip [package]`, describe a package to be handled using `pip`.

- `--N/npm [package]`, describe a package to be handled using `npm`.

- `--P/plugin [package]`, describe a fish plugin to be handled with either `omf` or `fisher`. To install, pass the **address** of its git repository.

## Disclaimer

> This script has only been tested on Termux and some Debian-based operating systems, both of which use the `apt` package manager by default. The commands for verification, installation, updating and uninstallation of other default package managers have been drawn from reference. If you experience problems using this script wih your default package manager, issue reports and pull requests will be most welcome.
