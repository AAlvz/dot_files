# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  standard_machine config, 'sms.rest', '192.168.33.10'
end

def standard_machine(config, hostname, ip)

    ### GET CUSTOMIZED OPTIONS
    require 'getoptlong'
    opts = GetoptLong.new(
      [ '--tags', GetoptLong::OPTIONAL_ARGUMENT ],
      [ '-f', GetoptLong::OPTIONAL_ARGUMENT ],
      [ '-h', GetoptLong::OPTIONAL_ARGUMENT ],
      [ '-c', GetoptLong::OPTIONAL_ARGUMENT ]
    )
    tags = ''
    opts.each do |opt, arg|
      case opt
      when '--tags'
        tags=arg
      end
    end

    ### Define machines
    config.vm.define hostname do |config|
      user = "tinkerware"
      group = "tinkerware"

    ### MACHINE CONFIGURATION
    config.vm.box = "ubuntu/trusty64"
    config.vm.network :private_network, ip: ip
    config.vm.hostname = hostname
    config.ssh.insert_key = false
    config.vm.synced_folder "tinker_shared_files", "/opt/tinker/shared_files", mount_options: ["uid=1010,gid=1010,dmode=755,fmode=644"], create: true, owner: 1010, group: 1010
    config.vm.provision "shell", inline: "sudo groupadd -g 1010 #{group} || true && sudo useradd -u 1010 #{user} -g #{group} -m -d /home/#{user}/ ||  true"

    ### Provider configurations
    config.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
      vb.customize ['modifyvm', :id, '--nictype2', 'virtio']
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.memory = 512
      vb.cpus   = 2
    end

    ### PROVISIONING
    config.vm.provision "ansible_local" do |ansible|
      ansible.install  = true
      ansible.playbook = "provisioning/site.yml"
      ansible.provisioning_path = "/vagrant"
      ansible.inventory_path = "provisioning/vagrant_hosts"
      ansible.verbose = true
      if tags != ''
        ansible.tags = "#{tags}"
      end
    end

    yield(config) if block_given?
  end
end
