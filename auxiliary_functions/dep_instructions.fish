function dep_instructions
  set -l bld (set_color 00afff -o)
  set -l reg (set_color normal)
  set -l instructions $bld"dependency

"$bld"DESCRIPTION

A plugin to install or remove packages that is system agnostic. It's meant for use on scripts.

"$bld"OPTIONS

"$bld"-i/--install"$reg" [-n/--name COMMAND]
Install packages. This is the default option. Optionally, the name of a command that requires such dependencies to be installed can be displayed by passing it with the flag "$bld"-n/--name"$reg".

"$bld"-u/--uninstall"$reg" [-f/--force BINARY]
Uninstall pagkages. By using the flag "$bld"-f/--force"$reg" one can uninstall a dependency by simply deleting its binary

"$bld"--pip"$reg" [PACKAGE]
Describe a package to be handled using "$bld"pip"$reg".

"$bld"--pip3"$reg" [PACKAGE]
Describe a package to be handled using "$bld"pip3"$reg".

"$bld"--npm"$reg" [PACKAGE]
Describe a package to be handled using "$bld"npm"$reg".

"$bld"--plugin"$reg" [PACKAGE]
Describe a plugin to be handled with either "$bld"omf"$reg" or "$bld"fisher"$reg" by passing the "$bld"full address"$reg" of its git repository." | less -R
end