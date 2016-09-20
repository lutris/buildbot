#!/bin/bash

set -e

container=$1
user='ubuntu'

lxc exec $container -- ls -la
lxc exec $container -- apt -y install wget curl build-essential git python openssh-server zsh
lxc exec $container -- mkdir -p /home/$user/.ssh
lxc file push ~/.ssh/id_rsa $container/home/$user/.ssh/
lxc file push ~/.ssh/id_rsa.pub $container/home/$user/.ssh/
#lxc exec $container -- passwd $user
lxc exec $container -- chsh -s /bin/zsh ubuntu
lxc file push --uid=1000 --gid=1000 ./setup-userspace.sh $container/home/$user/
lxc exec $container -- chmod +x /home/$user/setup-userspace.sh
