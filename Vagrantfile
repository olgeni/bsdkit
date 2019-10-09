# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  config.ssh.shell = "/bin/sh"
  config.ssh.forward_agent = true

  config.vm.box = "freebsd/FreeBSD-12.0-RELEASE"
  config.vm.boot_timeout = 3600

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    pkg install -y git py36-ansible
  SHELL

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    cd /vagrant/playbook
    ansible-playbook -i localhost, -c local -e ansible_python_interpreter=/usr/local/bin/python3 bsdkit.yml
    pkg upg -y
    pkg autoremove -y
    pkg clean -ay
  SHELL
end
