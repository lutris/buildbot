# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://docs.vagrantup.com.

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/buildbot"
  config.vm.provision "shell", path:"setup-buildbot.sh"
end