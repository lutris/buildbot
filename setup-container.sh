#!/bin/bash
set -x

container=$1
user='ubuntu'

InstallDependencies() {
    sudo lxc file push setup-buildbot.sh $container/home/$user/
    sudo lxc exec $container -- sudo bash -c /home/$user/setup-buildbot.sh
}

SetupSSH() {
    sudo lxc exec $container -- mkdir -p /home/$user/.ssh
    sudo lxc exec $container -- chown $user /home/$user/.ssh
    sudo lxc file push ~/.ssh/config $container/home/$user/.ssh/
}

SetupUserspace() {
    sudo lxc exec $container -- git clone https://github.com/lutris/buildbot.git /home/$user/buildbot
    sudo lxc exec $container -- chown -R ubuntu:ubuntu /home/$user/buildbot
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
