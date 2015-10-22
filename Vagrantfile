# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

PRIVATE_NET = "192.168.73"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = "devstack"
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "rarguello/fedora-22"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "#{PRIVATE_NET}.10"

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://#{PRIVATE_NET}.1:3128/"
    config.proxy.https    = "http://#{PRIVATE_NET}.1:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1,#{PRIVATE_NET}.1"
  end

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  #config.vm.synced_folder ".", "/vagrant", type: "nfs"
  #config.vm.synced_folder ".", "/vagrant", type: "9p"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = 4096
    vb.cpus = 2
  end

  config.vm.provider "libvirt" do |domain|
    domain.memory = 4096
    domain.cpus = 2
    domain.nested = true
#    domain.volume_cache = 'none'
  end



  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
#    cat > /tmp/pip.conf <<EOF
#[global]
#index-url = http://#{PRIVATE_NET}.1:3141/root/pypi/+simple/
#trusted-host = #{PRIVATE_NET}.1
#EOF
#    sudo cp /tmp/pip.conf /etc
#    sudo sed -i 's/^#baseurl/baseurl/' /etc/yum.repos.d/*
#    sudo sed -i 's/^metalink/#metalink/' /etc/yum.repos.d/*
#    sudo sed -i 's,download.fedoraproject.org/pub,mirror2.hs-esslingen.de,' /etc/yum.repos.d/*
    sudo dnf install -y rsyslog joe yum-utils net-tools nfs-utils mlocate telnet sudo git dnf
    chmod o+x .
#    git clone /vagrant/repos/openstack-dev/devstack
    git clone https://git.openstack.org/openstack-dev/devstack
    cp /vagrant/local.conf devstack/
    cd devstack
    ./stack.sh |& tee /tmp/stack.log
    sudo systemctl enable openvswitch mariadb rabbitmq-server httpd
  SHELL
end
