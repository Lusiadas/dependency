function dependency -d 'install a missing dependency'

  # Load dependencies
  for function in (dirname (status -f))/../auxiliary_functions/dep_*.fish
    source $function
  end
  dep_plugin https://gitlab.com/lusiadas/feedback

  # Parse argument
  function dep_main
    if not argparse -x (string join -- ' -x ' h,{n,i,u,f,p,P,n,N,f,F} i,{u,f} u,n | string split ' ') 'i/install' 'n/name=' 'u/uninstall' 'f/force=+' 'p-pip=+' 'P-pip3=+' 'N-npm=+' 'F-plugin=+' 'h/help' -- $argv 2>"$PREFIX"/tmp/err
      err (head -1 "$PREFIX"/tmp/err | string match -r '(?<=: ).+')
      reg -e "Use |dependency -h| to see examples of valid syntaxes\n"
      return 1
    end

    # Print instructions
    if set --query _flag_help
      dep_instructions
      test "$argv"
      and return 1
      or return 0
    end

    # Check available dependencies
    set -l sudo
    set -l dependencies $argv $_flag_pip $_flag_pip3 $_flag_npm $_flag_plugin $_flag_force
    set -l installed
    set -l not_installed
    set -l can_install
    for dependency in $dependencies
      type -q (basename $dependency)
      and set installed $installed $dependency
      or set not_installed $not_installed $dependency
    end

    # Check for available permissions
    if type -qf termux-info
      set can_install true
    else if id -u $USER | string match -qv 0
      set can_install true
    else if type -qf sudo
      if id -g $USER | string match -qe sudo
        set can_install true
        set sudo sudo
      end
    end

    # Remove dependencies
    if test -n "$_flag_uninstall" -a -n "$installed"

      # Offer to uninstall dependencies
      set -l opt
      if test (count $installed) -eq 1
        read -p "wrn -n \"Uninstall dependency |$installed| as well? [y/n]: \"" opt
      else
        read -p "wrn -n 'Uninstall some dependencies as well? [y/n]: '" opt
      end
      string match -qr '(?i)^y(es)?$' $opt
      or return 0

      # List available dependencies
      if test (count $installed) -gt 1
        for i in (seq (count $installed))
          echo $i. $installed[$i]
        end
        printf '%s' (math (count $installed) + 1)'. all' \
        (math (count $installed) + 2)'. cancel'

        # Select dependencies to be removed
        read -lP 'Which? [list one or more]: ' opt2
        string match -qr -- "[^1-"(math (count $installed) + 1)"]" $opt2
        and return 0
        test $opt2 -le (count $installed)
        and set installed $installed[$opt2]
      end

      # Find the appropriate package manager to uninstall
      for dependency in $installed
        dim -n "Uninstalling |$dependency|... "
        contains $dependency $_flag_pip
        and command pip uninstall -y $_flag_pip >/dev/null 2>&1
        contains $dependency $_flag_pip3
        and command pip3 uninstall -y $_flag_pip3 >/dev/null 2>&1
        contains $dependency $_flag_npm
        and command npm uninstall $package >/dev/null 2>&1
        contains $dependency $_flag_plugin
        and dep_plugin uninstall $_flag_plugin
        contains $dependency $_flag_force
        and command rm $dependency >/dev/null 2>&1
        if contains $dependency $argv
          if not test "$can_install"
            dim -o "You don't have the necessary permissions to uninstall |$dependency|"
            continue
          else if type -qf apt
            eval "$sudo" apt remove -y $dependency >/dev/null 2>&1
          else if type -qf zypper
            eval "$sudo" zypper rm -y $dependency >/dev/null 2>&1
          else if type -qf pacman
            eval "$sudo" pacman -Rs --noconfirm $dependency >/dev/null 2>&1
          else if type -qf yum
            eval "$sudo" yum remove -y $dependency >/dev/null 2>&1
          else if type -qf dnf
            eval "$sudo" dnf remove -y $dependency >/dev/null 2>&1
          else if type -qf emerge
            eval "$sudo" emerge -c $dependency >/dev/null 2>&1
          else
            wrn -o "A package manager has not been identified"
            reg "Please uninstall |"(string join '|, |' $installed)"| using your available package manager"
            return 0
          end
        end
        reg -o "|$dependency| removed."
      end

    #Install dependencies
    else if test -z "$_flag_uninstall" -a -n "$not_installed"

      # Ask for confirmation
      if set --query _flag_name
        set -l opt
        if test (count $dependencies) -eq 1
          read -p "wrn -n \"Plugin |$_flag_name| requires dependency |$dependencies|. Install it? [y/n]: \"" opt
        else
          read -p "wrn -n \"Plugin |$_flag_name| requires dependencies |"(string join "|, |" $dependencies)"|. Install them? [y/n]: \"" opt
        end
        string match -qr '(?i)^y(es)?$' $opt
        or return 1
      end

      # Find appropriate package manager to install
      for dependency in $dependencies
        if type -q $dependency
          reg "|$dependency| already installed."
          continue
        end
        dim -n "Installing |$dependency|... "
        contains $dependency $_flag_pip
        and command pip install -y $_flag_pip >/dev/null 2>&1
        contains $dependency $_flag_pip3
        and command pip3 install -y $_flag_pip3 >/dev/null 2>&1
        contains $dependency $_flag_npm
        and command npm install $package >/dev/null 2>&1
        contains $dependency $_flag_plugin
        and dep_plugin $_flag_plugin
        if contains $dependency $argv
          if not test "$can_install"
            dim -o "You don't have the necessary permissions to uninstall |$dependency|"
            continue
          else if type -qf apt
            eval "$sudo" apt install -y $dependency >/dev/null 2>&1
          else if type -qf zypper
            eval "$sudo" zypper in -y $dependency >/dev/null 2>&1
          else if type -qf pacman
            eval "$sudo" pacman -S --noconfirm $dependency >/dev/null 2>&1
          else if type -qf yum
            eval "$sudo" yum install -y $dependency >/dev/null 2>&1
          else if type -qf dnf
            eval "$sudo" dnf install -y $dependencies >/dev/null 2>&1
          else if type -qf emerge
            eval "$sudo" emerge $dependencies >/dev/null 2>&1
          else
            wrn -o "A package manager has not been identified"
            reg "Please install |"(string join '|, |' $not_installed)"| using your available package manager"
            return 0
          end
        end
        reg -o "|$dependency| added."
      end
    end
  end

  # Call main function and unload auxiliary functions before finishing
  dep_main $argv
  set -l exit_status $status
  functions -e (functions | string match -ar '^dep_.+')
  test $exit_status -eq 0
end
