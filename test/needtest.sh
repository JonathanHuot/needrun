#!/bin/false

wd=$(dirname $BASH_SOURCE)/..
[ -f $wd/needrun.sh ] || return 1
. $wd/needrun.sh

tmp=$(mktemp -d)

needtool diff || return 1
needfile $wd/needrun.sh $tmp/yy || return 1
needfile $tmp/yy $tmp/zz || return 1
needcmd diff $tmp/yy $tmp/zz || return 1

needtool fakediff && return 1
needcmd fakediff foo bar && return 0

needuser $USER || return 1

needgit https://github.com/JonathanHuot/needrun.git $tmp || return 1
needcmd grep needgit $tmp/needrun.sh || return 1

return 0
