# needrun
Project aims to be the shortest and simplest linux scripts to setup a brand new machine for an application.

## Download and Install
Make a copy of this file in your project

`curl -O https://raw.githubusercontent.com/JonathanHuot/needrun/master/needrun.sh`

## Usage
### needrun - boostrap
Recommanded option is to create a shell script to setup your application on your server. Then, start with this line:

`source <needrun.sh location>`

### needfile - copy a file from your workspace
`needfile linux/yum.nginx.repo /etc/yum.repos.d/ || return`


### needyum - package with yum based distro (Centos/Red Hat/Fedora/Oracle Linux...)
`needyum nginx || return`


### neednpm - package with NodeJS npm based
`neednpm bower || return`


### needcmd - run an arbitrary shell command
`needcmd systemctl restart nginx || return`


### needtool - check if a command is present
`needtool bower || return`

## Full example of web python project using MongoDB on Centos7

Below example is using `nginx` for HTTP web server, `supervisord` for running python application, `pip` for python packages, `npm` for NodeJS packages, `MongoDB` for database.
Note that Node JS is installed to have some external tools like `lessc` or `bower`.

```
source $(dirname $0)/needrun.sh
# build dependencies
needyum https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm || return

needyum python-pip

# deps for flanker (pip package) which needs cryptography which is built with gcc:
needyum libffi-devel || return
needyum openssl-devel || return 

needyum python-virtualenv || return
needyum gcc-c++ || return
needyum make || return
needyum git || return

needcmd curl --silent --location https://rpm.nodesource.com/setup_5.x | bash - || { echo "node installation failed" && return; }
needyum nodejs || return

needfile linux/yum.nginx.repo /etc/yum.repos.d/ || return
needyum nginx || return
needyum supervisor || return

needfile linux/yum.mongodb.repo /etc/yum.repos.d/ || return
needyum mongodb-org || return

# Node JS packages
neednpm bower || return
neednpm less || return

# Verify if above commands installed the right tools
if [[ -f /usr/bin/python2.7 ]]; then
  py=2.7
fi

needtool python$py || return
needtool virtualenv || return
needtool bower || return
needtool lessc || return
needtool pip || return

needfile linux/supervisor.paperboy.ini /etc/supervisord.d/
needfile linux/nginx.paperboy.conf /etc/nginx/conf.d/

needcmd bower --allow-root install || { echo "bower install failed" && return; }

[[ ! -d /var/lib/paperboy/env ]] && virtualenv -p /usr/bin/python$py --system-site-packages /var/lib/paperboy/env
. /var/lib/paperboy/env/bin/activate
needcmd pip install -r requirements.txt || { echo "python dependencies failed" && return; }
deactivate

needcmd systemctl enable mongod
needcmd systemctl enable supervisord
needcmd systemctl enable nginx
needcmd systemctl restart mongod
needcmd systemctl restart supervisord
needcmd systemctl restart nginx
echo "environment is ready"
```
