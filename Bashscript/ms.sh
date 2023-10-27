#/bin/bash

vagrant init ubuntu/jammy64

cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|

  config.vm.define "master" do |master|

    master.vm.hostname = "master"
    master.vm.box = "ubuntu/jammy64"
    master.vm.network "private_network", ip: "192.168.20.17"

    master.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

  config.vm.define "slave" do |slave|

    slave.vm.hostname = "slave-1"
    slave.vm.box = "ubuntu/jammy64"
    slave.vm.network "private_network", ip: "192.168.20.18"

    slave.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

    config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "2"
    end
end
EOF

vagrant up

