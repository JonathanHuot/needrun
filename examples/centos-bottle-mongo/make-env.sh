#!/bin/false

# bootstrap needrun
source $(dirname $0)/needrun.sh || { echo "please download needrun.sh" && return; }

# setup vars, if needed
src=./

# build dependencies
needcmd rpm -q epel-release \
    || needyum https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    || return

needyum python-pip

# deps for flanker (pip package) which needs cryptography which is built with gcc:
needyum libffi-devel || return
needyum openssl-devel || return 

needyum python-virtualenv || return
needyum gcc-c++ || return
needyum make || return
needyum git || return

needtool npm ||
    needcmd curl --silent --location https://rpm.nodesource.com/setup_5.x | bash - || { echo "node installation failed" && return; }
needyum nodejs || return

needfile "$src/yum.nginx.repo" /etc/yum.repos.d/ || return
needyum nginx || return
needyum supervisor || return

needfile "$src/yum.mongodb.repo" /etc/yum.repos.d/ || return
needyum mongodb-org || return

# Node JS packages
neednpm bower || return
neednpm less || return

needtool python || return
needtool virtualenv || return
needtool bower || return
needtool lessc || return
needtool pip || return

needfile "$src/supervisor.needrun.ini" /etc/supervisord.d/
needfile "$src/nginx.needrun.conf" /etc/nginx/conf.d/

needcmd bower --allow-root install || { echo "bower install failed" && return; }

[[ ! -d /var/lib/bottle/env ]] && virtualenv --system-site-packages /var/lib/needrun/env
. /var/lib/needrun/env/bin/activate
needcmd pip install -r requirements.txt || { echo "python dependencies failed" && return; }
deactivate

needcmd systemctl enable mongod
needcmd systemctl enable supervisord
needcmd systemctl enable nginx
needcmd systemctl restart mongod
needcmd systemctl restart supervisord
needcmd systemctl restart nginx
echo "environment is ready"
