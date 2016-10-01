#!/bin/bash

set -e

container=$1
user='ubuntu'

InstallDependencies() {
    lxc exec $container -- apt update
    lxc exec $container -- apt -y install wget curl build-essential git python openssh-server zsh
}

SetupSSH() {
    lxc exec $container -- mkdir -p /home/$user/.ssh
    if [[ $container == *"64"* ]]; then
        key_folder=./ssh/buildbot64
    else
        key_folder=./ssh/buildbot32
    fi
    lxc file push ./ssh/authorized_keys $container/home/$user/.ssh/
    lxc file push ./ssh/config $container/home/$user/.ssh/
    lxc file push ${key_folder}/id_rsa $container/home/$user/.ssh/
    lxc file push ${key_folder}/id_rsa.pub $container/home/$user/.ssh/
}

SetupUser() {
    lxc exec $container -- passwd $user
    lxc exec $container -- chsh -s /bin/zsh $user
    lxc file push --uid=1000 --gid=1000 ./setup-userspace.sh $container/home/$user/
}

SetupUserspace() {
    lxc exec $container -- chmod +x /home/$user/setup-userspace.sh
}

SetupHost() {
    if [[ $container == *"64"* ]]; then
        other_container="${container%amd64}i386"
        other_hostname="buildbot32"
    else
        other_container="${container%i386}amd64"
        other_hostname="buildbot64"
    fi
    other_ip=$(lxc list $other_container -c 4 | grep eth0 | cut -d" " -f 2)
    if [[ "$other_ip" = "" ]]; then
        echo "Other container $other_container is not reachable"
        exit 2
    fi
    lxc exec $container -- bash -c "echo $other_ip   $other_hostname >> /etc/hosts"
}

if [ $2 ]; then
    $2
else
    InstallDependencies
    SetupHost
    SetupSSH
    SetupUser
    SetupUserspace
fi
