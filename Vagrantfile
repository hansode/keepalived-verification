# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-6.4-x86_64"

  config.vm.provider :virtualbox do |v, override|
   # Disable the base shared folder, guest additions are unavailable.
    override.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.vm.provision "shell", path: "bootstrap.sh"     # Bootstrapping: package installation (phase:1)
  config.vm.provision "shell", path: "config.d/base.sh" # Configuration: node-common          (phase:2)

  1.times.each { |i|
    name = sprintf("node%02d", i + 1)
    config.vm.define "#{name}" do |node|
      node.vm.hostname = "#{name}"
      node.vm.provision "shell", path: "config.d/#{node.vm.hostname}.sh" # Configuration: node-specific (phase:2.5)
     end
  }
end
