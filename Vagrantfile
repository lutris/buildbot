# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.synced_folder ".", "/home/vagrant/lutris-buildbot", id: "lutris-buildbot", type: "rsync"
  config.vm.provision "shell", path:"setup-buildbot.sh"
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 8
    libvirt.memory = 16384
  end
end
