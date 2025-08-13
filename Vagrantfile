# Require YAML module
require 'yaml'
 
# Read YAML file with box details
nodes = YAML.load_file('nodes.yaml')
 
# Create boxes
Vagrant.configure(2) do |config|
  nodes.each do |nodes|
    config.vm.define nodes["name"] do |srv|
			srv.vm.hostname = nodes['hostname']
      srv.vm.box = nodes["box"]
      srv.vm.network nodes['network_type'], bridge: nodes['network_interface'], ip: nodes['public_ip']
      srv.vm.provision "shell" do |s|
        ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
        s.inline = <<-SHELL
          ## user setup
          echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
          echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
          date > /etc/vagrant_provisioned_at
        SHELL
      end
      srv.vm.provider :virtualbox do |vb|
        vb.name = nodes["name"]
        vb.memory = nodes["ram"]
      end
    end
  end
end
