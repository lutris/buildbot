#!/bin/bash
set -x

container=$1
user='ubuntu'

InstallDependencies() {
    sudo lxc exec $container -- apt update
    sudo lxc exec $container -- apt -y full-upgrade
    # this package is necessary to add repositories using add-apt-repository
    sudo lxc exec $container -- apt -y install software-properties-common
    sudo lxc exec $container -- add-apt-repository ppa:cybermax-dexter/sdl2-backport -y
    sudo lxc exec $container -- add-apt-repository ppa:cybermax-dexter/vkd3d -y
    sudo lxc exec $container -- apt update
    sudo lxc exec $container -- apt -y install wget curl build-essential git python openssh-server s3cmd awscli vim zsh fontconfig
}

SetupSSH() {
    sudo lxc exec $container -- mkdir -p /home/$user/.ssh
    sudo lxc exec $container -- chown ubuntu /home/$user/.ssh
    sudo lxc file push ~/.ssh/config $container/home/$user/.ssh/
}

SetupUserspace() {
    sudo lxc file push -r ../buildbot $container/home/$user/
}

SetupHost() {
    if [[ $container == *"64"* ]]; then
        other_container="${container%amd64}i386"
        other_hostname="buildbot32"
    else
        other_container="${container%i386}amd64"
        other_hostname="buildbot64"
    fi
    other_ip=$(sudo lxc list $other_container -c 4 | grep eth0 | cut -d" " -f 2)
    if [[ "$other_ip" = "" ]]; then
        echo "Other container $other_container is not reachable"
        exit 2
    fi
    sudo lxc exec $container -- bash -c "echo $other_ip   $other_hostname >> /etc/hosts"
}

if [ $2 ]; then
    $2
else
    InstallDependencies
    SetupHost
    SetupSSH
    SetupUserspace
fi
