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
      or return 1
      set -l install_script \
      $OMF_PATH/pkg/(command basename $argv)/hooks/install.fish
      test -e "$install_script"
      and fish "$install_script"
      for function in \
      (command realpath -s $OMF_PATH/pkg/(command basename $argv)/functions/*)
        source $function
      end
  end
end
dep_plugin https://gitlab.com/lusiadas/feedback

# Parse arguments
if argparse -n dependency 'r/remove' 'n/name=' 'f/force=+' 'N/npm=+' 'p/pip=+' 'P/plugin=+' -- $argv 2>&1 | read err 
  err $err
  exit 1
end
set -l --append _flag_plugin (omf list | string match -qr "\b(feedback|contains_opts)\b")

# Check for available permissions
set -l sudo
if command id -u | string match -qv 0
  if command groups | string match -qe sudo
    type -qf sudo
    and set sudo sudo
  end
end

# Check for a default package manager
test -n "$_flag_remove"
and dim -n "Checking available package managers..."
set -l verify
set -l install
set -l remove
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
  err "A package manager wasn't found to handle |"(string join '|, |' $argv)"|"
  reg 'Ignoring... '
  set --erase argv
end

# Search for an specific package manager
if test -n "$_flag_pip" -o -n "$_flag_npm"
  set -l flags _flag_pip pip python _flag_npm npm nodejs
  for i in 1 4
    set --query $flags[$i]
    or continue
    if not type -qf $flags[(math $i + 1)]
      set -l failed
      if test -z "$install"
        set failed true
      else if read -n 1 -p "wrn -n \"|"$flags[(math $i + 2)]"| isn't installed. Install it before proceding with installation? [y/n]: \"" | string match -viq y
        set failed true
      end
      if test -z "$failed"
        dim -on "Installing |"$flags[(math $i + 2)]"|... "
        eval $install $flags[(math $i + 2)] >/dev/null 2>&1
        and reg -o "|"$flags[(math $i + 2)]"| installed"
        or set failed true
      end
      if test "$failed"
        string match -q $flags[$i] _flag_pip
        and set -l packages $_flag_pip
        or set -l packages $_flag_npm
        err -o "|"$flags[(math $i + 2)]"| isn't installed. Cancelling the installation of |"(string join '|, |' $packages)"|"
        set --erase $flags[$i]
      end
    end
  end
end

# Check if package is installed
set --query _flag_remove
and dim -on "Checking for dependencies... "
set -l installed
set -l not_installed
for dependency in (command printf '%s\n' $argv $_flag_pip $_flag_npm $_flag_plugin $_flag_force \
| command awk '!x[$0]++')
  if type -q (command basename $dependency)
    set -a installed $dependency
    continue
  end
  if contains $dependency $argv
    if eval $verify $dependency >/dev/null 2>&1
      set -a installed $dependency
      continue
    end
  end
  if contains $dependency $_flag_plugin $argv
    if dep_plugin check $dependency
      set -a installed $dependency
      continue
    end
  end
  if contains $dependency $_flag_pip $argv
    if type -qf pip
      if pip show -q $dependency 2>/dev/null
        set -a installed $dependency
        continue
      end
    end
  end
  if contains $dependency $flag_npm $argv
    if type -qf npm
      if npm list -g | string match -qe $dependency
        set -a installed $dependency
        continue
      end
    end
  end
  set not_installed $not_installed $dependency
end

# Remove dependencies
if test -n "$_flag_remove" -a -n "$installed"

  # Offer to uninstall dependencies
  echo -en \r(tput el)
  if test (count $installed) -eq 1
    read -n 1 -p "wrn \"Uninstall dependency |$installed|? [y/n]: \"" \
    | string match -qir y
  else
    read -n 1 -p "wrn 'Uninstall some dependencies as well? [y/n]: '" \
    | string match -qir y
  end
  or exit 0

  # List available dependencies
  if test (count $installed) -gt 1
    for i in (seq (count $installed))
      echo $i. $installed[$i]
    end
    reg -e '[a]. |all|\n[c]. |cancel|'

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
  end

  # Find the appropriate package manager to uninstall
  for dependency in $installed
    dim -n "Uninstalling |$dependency|... "
    if contains $dependency $argv
      if eval "$sudo" $uninstall $dependency >/dev/null 2>&1
        reg -o "|$dependency| removed."
        continue
      end
    end
    if contains $dependency $_flag_pip $argv
      if command pip list | string match -qr '^youtube-dl\b'
        command pip uninstall -y $dependency >/dev/null 2>&1
        reg -o "|$dependency| removed."
        continue
      end
    end
    if contains $dependency $_flag_plugin
      if dep_plugin uninstall $dependency
        reg -o "|$dependency| removed."
        continue
      end
    end
    if contains $dependency $flag_npm
      if command npm list -g | string match -qr "\b$dependency(?=@)"
        command npm uninstall -g $dependency >/dev/null 2>&1
        reg -o "|$dependency| removed."
        continue
      end
    end
    if contains $dependency $_flag_force
      if command rm $dependency >/dev/null 2>&1
        reg -o "|$dependency| removed."
        continue
      end
    end
    err -o "Failed to uninstall |$dependency|"
  end
  omf list | string match -qr "\bfeedback\b"
  and omf list | not string match -qr "\bcontains_opts\b"
  and dep_plugin uninstall feedback
  and reg -o "|feedback| removed."

# Install dependencies
else if test -z "$not_installed"
  exit 0

else
  # Ask for confirmation
  if test -n "$_flag_name" -a -n "$not_installed"
    test (count $not_installed) -eq 1
    and wrn -o "Plugin |$_flag_name| requires dependency |"(string match -ar '[^/]+$' $not_installed)"|. Install it? [y/n]: "
    or wrn -o "Plugin |$_flag_name| requires dependencies |"(string match -ar '[^/]+$' $not_installed | string join '|, |')"|. Install them? [y/n]: "
    read -n 1 | string match -qir y
    or exit 1
  end

  # Find appropriate package manager to install
  set -l failed
  for dependency in $not_installed
    dim -on "Installing |"(command basename $dependency)"|... "
    if contains $dependency $argv
      eval "$sudo" $install $dependency >/dev/null 2>&1
    else if contains $dependency $_flag_pip
      command pip install --user $dependency >/dev/null 2>&1
    else if contains $dependency $_flag_plugin
      dep_plugin $dependency
    else if contains $dependency $_flag_npm
      command npm install -g $dependency >/dev/null 2>&1
    end
    if $status = 0
      reg -o "|$dependency| was installed"
      continue    
    end
    err -o "Failed to install |$dependency|"
    set failed true
  end
  functions -e (functions | string match -ar '^dep_.+')
  test -z "$failed"
end
