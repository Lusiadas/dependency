source $path/auxiliary_functions/dep_plugin.fish
read -p "wrn -n \"Remove dependencies |feedback| and |contains_opts| as well?\"" | string match -qr '^(?i)^y(es)?$'
and dep_plugin uninstall https://gitlab.com/lusiadas/{feedback,contains_opts}
functions -e dep_plugin
