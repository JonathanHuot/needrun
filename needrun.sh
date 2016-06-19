#!/bin/false

wd=$(dirname $BASH_SOURCE)/../

unset __yum
unset __npm
unset __pip

function needcmd
{
    $* || { echo "command <$*> failed" && return 1; }
    return 0
}

function needuser
{
  user=$1
  id $user 2> /dev/null || useradd -m photos || { echo "useradd failed" && return 1; }

  echo "user $user found."
  return 0
}

function needtool
{
  tool=$1
  which $tool > /dev/null || { echo "please install $tool" && return 1; }

  echo "tool $tool found."
  return 0
}

function needfile
{
    src=$1
    dest=$2
    filename=$(basename $1)
    [[ ! -f $src ]] && echo "source $src not found" && return 1
    [[ -d $dest && -r $dest/$filename && $(diff -q $src $dest/$filename) == "" ]] && echo "$dest/$filename found" && return 0
    [[ -f $dest && $(diff -q $src $dest) == "" ]] && echo "$dest found" && return 0

    [ ! -w $dest ] && echo "need permissions to $dest" && return 1
    
    /bin/cp -f $wd/$src $dest || return 1
    echo "$wd/$src copied to $dest."
    return 0
}

function needyum
{
    [ -z $__yum ] && { needtool yum > /dev/null || { echo "yum is missing, skip unsupported platform" && return; } }
    __yum=1

    rpmname=$1
    rpmshortname=$(echo $rpmname | awk -F/ '{print $NF}'|sed 's/.rpm$//')
    rpm -q "$rpmshortname" > /dev/null && { echo "$rpmname already installed" && return 0; }

    yum -y install $rpmname
    return $?
}

function neednpm
{
    [ -z $__npm ] && { needtool npm > /dev/null || { echo "npm is missing, please install nodejs first" && return; } }
    __npm=1

    nodepackage=$1
    npm list -g $nodepackage >/dev/null && echo "$nodepackage found" && return 0
    npm install -g $nodepackage || { echo "npm install $nodepackage failed" && return 1; }
    echo "$nodepackage installed"
    return 0
}

function needpip
{
    [ -z __pip ] && { needtool pip > /dev/null || { echo "pip is missing, please install python-pip first" && return; } }
    __pip=1

    package=$1
    (pip show $package >/dev/null) && echo "$package found" && return 0
    pip install $package || { echo "pip install $package failed" && return 1; }
    echo "$package installed"
    return 0
}
