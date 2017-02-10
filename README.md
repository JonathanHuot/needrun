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

### Advanced examples

- [Web Python project with MongoDB on Centos7](examples/centos-bottle-mongo/make-env.sh) - `nginx` for HTTP web server, `supervisord` for bottle application, `pip` and `npm` python/NodeJS packages, `MongoDB` for database. Note that Web server is Python-based, but Node JS is installed to have some external tools like `lessc` or `bower`.
