if test (fish --version | string match -ar '\d' | string join '') -lt 300
  set_color red
  echo 'This plugin is compatible with fish version 3.0.0 or above, please update before trying to use it' 1>&2
  set_color normal
  exit 1
end

# Load dependency
function dep_plugin -d "Install or uninstall a fish plugin"
  switch "$argv[1]"
    case uninstall
      omf remove (command basename $argv[2]) >/dev/null 2>&1
    case check
      omf list | string match -qr "\b"(command basename $argv[2])"\b"
    case '*'
      type -t (command basename $argv) 2>/dev/null \
      | string match -q function
      and return 0
      omf list | string match -qr "\b"(command basename $argv)"\b"
      and return 0
      omf install $argv 2>&1 \
      | not string match -qr '^(Error$|Could not install)'
  end
end
dep_plugin https://gitlab.com/argonautica/feedback

# Parse arguments
if argparse -n dependency 'r/remove' 'n/name=' 'f/force=+' 'N/npm=+' 'p/pip=+' 'P/plugin=+' -- $argv 2>&1 | read err
  err $err
  exit 1
end

# Declare variables
set -l --append _flag_plugin https://gitlab.com/argonautica/contains_opts
set -l failed
set -l verify
set -l install
set -l remove
set -l installed
set -l not_installed
command id -u | string match -qv 0
and command groups | string match -qe sudo
and type -qf sudo
and set -l sudo sudo

# Check for a default package manager
if type -qf apt
  set verify "dpkg -s"
  set install 'apt install -y'
  set remove "apt remove -y"
else if type -qf pacman
  set verify 'pacman -Qi'
  set install 'pacman -S --noconfirm'
  set remove 'pacman -Rs --noconfirm'
else if type -qf zypper
  set verify 'rpm -q'
  set install 'zypper in -y'
  set remove 'zypper rm -y'
else if type -qf yum
  set verify 'rpm -q'
  set install 'yum install -y'
  set remove 'yum remove -y'
else if type -qf dnf
  set verify 'rpm -q'
  set install 'dnf install -y'
  set remove 'dnf remove -y'
else if type -qf emerge
  set verify 'emerge -p'
  set install 'emerge'
  set remove 'emerge -c'
else if test "$argv"
  err "dependency: A package manager wasn't found to handle |"(string join '|, |' $argv)"|"
  reg 'Ignoring... '
  set --erase argv
  set failed true
end

# Check if package is installed
for dependency in (command printf '%s\n' $argv $_flag_pip $_flag_npm $_flag_force $flag_plugin \
| command awk '!x[$0]++')
  type -q (command basename $dependency)
  if test $status = 1
    if contains $dependency $argv
      eval $verify $dependency >/dev/null 2>&1
    else if contains $dependency $_flag_plugin
      dep_plugin check $dependency
    else if contains $dependency $_flag_pip
      type -qf pip
      and pip show -q $dependency 2>/dev/null
    else if contains $dependency $flag_npm
      type -qf npm
      and npm list -g | string match -qe $dependency
    end
  end
  if test $status = 0
    set -a installed $dependency
    continue
  end
  set --append not_installed $dependency
end

# Ask for confirmation before installing or uninstalling packages
if test -n "$_flag_remove"

  # Offer to uninstall dependencies
  if string match -qv contains_opts "$installed"
    read -n 1 -P 'Uninstall some dependencies as well? [y/n]: ' \
    | string match -qir y
    or exit 0

    # List available dependencies
    for i in (count $installed | command xargs seq)
      string match -q contains_opts $installed[$i]
      and reg "$i. contains_opts, feedback"
      or reg "$i. $installed[$i]"
    end
    reg -e "[a]. |all|\n[c]. |cancel|"

    # Select dependencies to be removed
    read -P 'Which? [list one or more]: ' opt
    if string match -qvr -- '[\d,a-](ll)?' $opt
      reg "Dependency uninstall cancelled"
      exit 0
    else if not string match -qr -- 'a(ll)?' $opt
      set opt (string replace ',' ' ' $opt)
      set opt (string replace '-' '..' $opt)
      set installed $installed[$opt]
    end
  else
    read -n 1 -P 'Uninstall |contains_opts| and |feedback| as well? [y/n]: ' \
    | string match -qir y
    or exit 0
  end
  if contains contains_opts $installed
    set --append installed feedback
    set --append _flag_plugin feedback
  end

# Check the package managers needed for installation
else if test "$not_installed"
  if test -n "$_flag_pip" -o -n "$_flag_npm"
    set -l flags _flag_pip pip python _flag_npm npm nodejs
    for i in 1 4
      set --query $flags[$i]
      or continue
      type -qf $flags[(math $i + 1)]
      and continue
      test -n "$install"
      and read -n 1 -p "wrn \"|"$flags[(math $i + 2)]"| isn't installed. Install it before proceding with installation? [y/n]: \"" | string match -viq y
      if $status = 0
        dim "Installing |"$flags[(math $i + 2)]"|... "
        if eval $install $flags[(math $i + 2)] >/dev/null 2>&1
          reg -o "|"$flags[(math $i + 2)]"| installed"
          continue
        end
      end
      string match -q $flags[$i] _flag_pip
      and set -l packages $_flag_pip
      or set -l packages $_flag_npm
      err "dependency: |"$flags[(math $i + 2)]"| wasn't installed."
      reg "Cancelling the installation of |"(string join '|, |' $packages)"|"
      set not_installed (command printf '%s\n' $not_installed $packages \
      | command awk '!x[$0]++' )
      set failed true
    end
  end

  # Confirm installation
  if set --query _flag_name
    wrn "Plugin |$_flag_name| requires |"(string match -ar '[^/]+$' $not_installed \
    | command xargs basename --multiple \
    | string join '|, |')"|."
    if test (count $not_inatalled) = 1
      read -n 1 -P "Install it? [y/n]: " | string match -qir y
    else
      read -n 1 -P "Install them? [y/n]: " | string match -qir y
    end
    or exit 1
  end
end

# Install or uninstall
set --query _flag_remove
and set -l dependencies $installed
or set -l dependencies $not_installed
for dependency in (printf '%s\n' $dependencies | tac)
  set --query _flag_remove
  and dim -n "Uninstalling |$dependency|... "
  if contains $dependency $argv
    if set --query _flag_remove
      eval "$sudo" $remove $dependency >/dev/null 2>&1
    else
      eval "$sudo" $install $dependency >/dev/null 2>&1
    end
  else if contains $dependency $_flag_pip
    if set --query _flag_remove
      command pip uninstall -y $dependency 2>&1 \
      | not string match -qe 'not installed'
    else
      command pip install --user $dependency >/dev/null 2>&1
    end
  else if contains $dependency $_flag_plugin
    if set --query _flag_remove
      dep_plugin uninstall $dependency
    else
      dep_plugin $dependency
    end
  else if contains $dependency $_flag_npm
    if set --query _flag_remove
      command npm uninstall -g $dependency 2>&1 \
      | string match -qe removed
    else
      command npm install -g $dependency >/dev/null 2>&1
    end
  else if contains $dependency $_flag_force
    type -P $dependency | command xargs rm >/dev/null 2>&1
  end
  and continue
  set --query _flag_remove
  and err -o "dependency: Failed to uninstall |$dependency|"
  or err -o "dependency: Failed to install |$dependency|"
  set --erase dependencies[(contains -i $dependency $dependencies)]
  set failed true
end

# Output result, exit status, and terminate
if test "$dependencies"
  echo
  if set --query _flag_remove
    set_color green
    echo ✔ (string join , $dependencies) removed.
    set_color normal
  else
    win "|"(string join '|, |' $dependencies)"| added."
  end
end
functions -e dep_plugin
test -z "$failed"