#!/bin/bash
#
# need to write this up. It's quite awesome. Actual commands (well,
# variable definitions) are in libakg/dot/psqlrc-commands.d, symlink
# at ~/.psqlrc-commands.d is what you'd expect, using the home-dotdir
# to be friendlier to anyone who wants to copy this in (which they
# should) (because it's awesome)
#
# this part avoids doing the ridiculous stuff in build_psqlrc_commands
# when nothing's changed, mostly noticable when my system is waaay
# overloaded... so a lot.
set -e


update_psqlrc_commands()
{
    if [ -n "$(find ~/.psqlrc-commands.d/ -maxdepth 1 -name '*.sql' -newer $HOME/.local/share/psqlrc-commands.sql -print -quit)" ];
    then
        build_psqlrc_commands >| $HOME/.local/share/psqlrc-commands.sql
    fi
}

install_psqlrc_commands()
{
    build_psqlrc_commands >| $HOME/.local/share/psqlrc-commands.sql
}



build_psqlrc_commands()
{
    for fname in ~/.psqlrc-commands.d/*.sql; do
        cmdname=$(basename $fname|sed -e 's/.sql$//');
        sql=$(cat $fname| sed -z -r -e 's/\n/\\n/g' -e "s/([^\\'])([']+)/\1\2\2/g" -e "s/^/'/" -e "s/(\\n|\\\n)*$/'/")
        rc_txt=$(echo -E '\set' "$cmdname" "$sql")
        echo -E "$rc_txt"
        echo
    done
}

if [ -f "$HOME/.local/share/psqlrc-commands.sql" ]; then
  update_psqlrc_commands
else
  install_psqlrc_commands
fi
