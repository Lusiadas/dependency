dependency --plugin https://gitlab.com/lusiadas/contains_opts
set -l cmd (basename (status -f) | cut -f 1 -d '.')
set -l opts i install n name u uninstall f force p pip P pip3 N npm F plugin h help
complete -fc $cmd -n "not contains_opts h help i install u uninstall f force" -s i -l install -d \
'Install packages'
complete -fc $cmd -n "not contains_opts h help i install u uninstall n name" -s u -l uninstall -d \
'Uninstall packages'
complete -xc $cmd -n "not contains_opts (string match -vr '^i(nstall)?\$' $opts)" -s n -l name -d \
'Output the name of the a plugin or package'
complete -xc $cmd -n "not contains_opts (string match -vr '^u(ninstall)?\$' $opts)" -s f -l force -d \
'Uninstall a package by deleting its binary'
complete -xc $cmd -n "not contains_opts (string match -vr '^(i(nstall)?|u(ninstall)?)\$' $opts)" -s p -l pip -d \
'Describe a package to be handled using pip'
complete -xc $cmd -n "not contains_opts (string match -vr '^(i(nstall)?|u(ninstall)?)\$' $opts)" -s P -l pip3 -d \
'Describe a package to be handled using pip3'
complete -xc $cmd -n "not contains_opts (string match -vr '^(i(nstall)?|u(ninstall)?)\$' $opts)" -s N -l npm -d \
'Describe a package to be handled using npm'
complete -xc $cmd -n "not contains_opts (string match -vr '^(i(nstall)?|u(ninstall)?)\$' $opts)" -s F -l plugin -d \
'Describe a fish plugin'
complete -c $cmd -n "not contains_opts" -s h -l help -d \
'Display instructions'
