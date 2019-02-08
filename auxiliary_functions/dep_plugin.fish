function dep_plugin -d "Install or uninstall a fish plugin"
  for plugin in (string match -vr '^((un)?install|--)$' $argv[1]) $argv[2..-1]
    if string match -q uninstall $argv[1]
      omf remove (basename $plugin) >/dev/null 2>&1
      or fisher rm (basename $plugin) >/dev/null 2>&1
    else
      type -t (basename $plugin) 2>/dev/null | string match -q function
      and continue
      type -q omf
      and omf install $plugin >/dev/null 2>&1
      or fisher add $plugin >/dev/null 2>&1
    end
  end
end
