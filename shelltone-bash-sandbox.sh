# Disposable Bash sandbox startup file.
. "${SHELLTONE_ROOT:?shelltone launcher did not set SHELLTONE_ROOT}/shelltone.bash"
. "$SHELLTONE_ROOT/shelltone-aliases.sh"
shelltone_aliases_enable "${SHELLTONE_ALIAS_PACK:-starter}"
printf '%s\n' 'Shelltone Bash sandbox — run `shelltone configure` to choose a theme; type `exit` to leave.'
