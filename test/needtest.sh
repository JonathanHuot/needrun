#!/bin/false

wd=$(dirname $BASH_SOURCE)/..
[ -f $wd/needrun.sh ] || return 1
. $wd/needrun.sh

needcmd rm -f yy zz || return 1

needtool diff || return 1
needcmd touch yy || return 1
needfile yy zz || return 1
needcmd diff yy zz || return 1

needcmd rm -f yy zz || return 1

needtool fakediff && return 1
needcmd fakediff foo bar && return 0

needuser $USER || return 1

return 0
