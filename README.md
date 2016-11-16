## needrun

needrun aims to be the shortest and simplest linux BASH script for deploying software on a machine. Its particularity is to be *idempotent*.

## Installation
 Download `needrun.sh` file

```
curl -O https://raw.githubusercontent.com/JonathanHuot/needrun/master/needrun.sh
```

## Usage

Basic usage is to create a shell script containing needfile bootstrap and deployment instructions. Then, you only need to execute the shell script. Note that deployment instructions are not executed if already applied.

## Documentation

### bootstrap
Required to have all the functions loaded

`source needrun.sh`

### needfile
Copy a file from your workspace

`needfile linux/yum.nginx.repo /etc/yum.repos.d/ || return`

### needyum
Install a RPM package on yum based Linux distro (CentOS/Red Hat/Fedora/Oracle Linux...)

`needyum nginx || return`


### neednpm
Install a NodeJS package / npm based

`neednpm bower || return`


### needpip
Install a python package / pip based

`needpip bower || return`


### needcmd
Execute an arbitrary shell command - not *idempotent*

`needcmd systemctl restart nginx || return`


### needtool
Check if a command is present, and stop otherwise

`needtool bower || return`

## Examples

### Simple example

It installs nginx, install a vhost file, then restart the service.
```
source needrun.sh
needyum nginx || return
needfile nginx.mywebsite.conf /etc/nginx/conf.d/ || return
needcmd systemctl restart nginx || return
needcmd systemctl enable nginx || return
```

### Advanced example of Web Python project using MongoDB on Centos7

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
