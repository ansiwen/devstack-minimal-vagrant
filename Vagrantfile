# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

require 'yaml'
if File.file?('config.yaml')
  conf = YAML.load_file('config.yaml')
else
  raise "Configuration file 'config.yaml' does not exist."
end

if conf["local_git_repos"]
  GIT_BASE = "/repos"
else
  GIT_BASE = "https://git.openstack.org"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "devstack-vm"
  config.vm.hostname = "devstack-vm"

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ansiwen/devstack-base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: 192.168.73.10"

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
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #

  config.vm.provider "libvirt" do |domain, override|
    domain.memory = 4096
    domain.cpus = 2
    domain.nested = true
#    domain.volume_cache = 'none'
    if conf["local_git_repos"]
      override.vm.synced_folder conf["local_git_repos"], "/repos", type: "9p"
    end
  end

  config.vm.provider "virtualbox" do |vb, override|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = 4096
    vb.cpus = 2
    if conf["local_git_repos"]
      override.vm.synced_folder conf["local_git_repos"], "/repos"
    end
  end

  ## Provisioning

  if conf["yum_repo"]
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/^#baseurl/baseurl/' /etc/yum.repos.d/*
      sed -i 's/^metalink/#metalink/' /etc/yum.repos.d/*
      sed -i 's,http://download.fedoraproject.org/pub,#{conf["yum_repo"]},' /etc/yum.repos.d/*
    SHELL
  end

  if Vagrant.has_plugin?("vagrant-proxyconf") && conf["http_proxy"]
    config.proxy.http     = conf["http_proxy"]
    config.proxy.https    = conf["http_proxy"]
    config.proxy.no_proxy = "localhost,127.0.0.1"
    config.vm.provision "shell", inline: <<-SHELL
      dnf install -y git
      git config --system url."https://github.com/".insteadOf git@github.com:
      git config --system url."https://".insteadOf git://
    SHELL
  end

  config.vm.provision "shell", inline: <<-SHELL
    dnf install -y rsyslog joe yum-utils net-tools nfs-utils mlocate telnet sudo git dnf
  SHELL

  if conf["devpi_server"] && conf["devpi_port"] && conf["devpi_path"]
    config.vm.provision "shell", inline: <<-SHELL
      cat >/etc/pip.conf <<PIPCONF
[global]
index-url = http://#{conf["devpi_server"]}:#{conf["devpi_port"]}/#{conf["devpi_path"]}
trusted-host = #{conf["devpi_server"]}
PIPCONF
    SHELL
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    chmod o+x .
    git clone #{GIT_BASE}/openstack-dev/devstack
  SHELL

  config.vm.provision "file", source: "local.conf", destination: "devstack/local.conf"

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    cd devstack
    export GIT_BASE=#{GIT_BASE}
    ./stack.sh |& tee /tmp/stack.log
  SHELL

  config.vm.provision "shell", inline: <<-SHELL
    sudo systemctl enable openvswitch mariadb rabbitmq-server httpd
  SHELL

end
