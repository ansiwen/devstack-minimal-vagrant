# -*- mode: ruby -*-
# vi: set ft=ruby :

## which network prefix to use for fixed IPs (host: .1, devstack-vm: .10)
$PRIVATE_NET = "192.168.73"

### if you want to clone openstack from a local repo folder, set it here
### and make sure that the vm backend has read access to it.
### (on ferdora 22 with libvirt it helps to switch off SELinux)
#$LOCAL_GIT_REPOS = "repos"

### if you want to use an http proxy, install the vagrant-proxyconf plugin
### ('$ vagrant plugin install vagrant-proxyconf') and set the proxy here
#$HTTP_PROXY = "http://#{$PRIVATE_NET}.1:3128/"

### if you use an http proxy, you should also set a specific, local and cache-
### friendly repo here
#$YUM_REPO = "http://ftp-stud.hs-esslingen.de/pub"

### if you have a local devpi server running, uncomment and set these two lines
#$DEVPI_SERVER = "#{$PRIVATE_NET}.1"
#$DEVPI_URL = "http://#{$DEVPI_SERVER}:3141/root/pypi/+simple/"


################################################################################

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

if defined? $LOCAL_GIT_REPOS
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
  config.vm.network "private_network", ip: "#{$PRIVATE_NET}.10"

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
    if $LOCAL_GIT_REPOS
      override.vm.synced_folder $LOCAL_GIT_REPOS, "/repos", type: "9p"
    end
  end

  config.vm.provider "virtualbox" do |vb, override|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = 4096
    vb.cpus = 2
    if $LOCAL_GIT_REPOS
      override.vm.synced_folder $LOCAL_GIT_REPOS, "/repos"
    end
  end

  ## Provisioning

  if $YUM_REPO
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/^#baseurl/baseurl/' /etc/yum.repos.d/*
      sed -i 's/^metalink/#metalink/' /etc/yum.repos.d/*
      sed -i 's,http://download.fedoraproject.org/pub,#{$YUM_REPO},' /etc/yum.repos.d/*
    SHELL
  end

  if Vagrant.has_plugin?("vagrant-proxyconf") && $HTTP_PROXY
    config.proxy.http     = $HTTP_PROXY
    config.proxy.https    = $HTTP_PROXY
    config.proxy.no_proxy = "localhost,127.0.0.1,#{$PRIVATE_NET}.1"
    config.vm.provision "shell", inline: <<-SHELL
      dnf install -y git
      git config --system url."https://github.com/".insteadOf git@github.com:
      git config --system url."https://".insteadOf git://
    SHELL
  end

  config.vm.provision "shell", inline: <<-SHELL
    dnf install -y rsyslog joe yum-utils net-tools nfs-utils mlocate telnet sudo git dnf
  SHELL

  if $DEVPI_SERVER && $DEVPI_URL
    config.vm.provision "shell", inline: <<-SHELL
      cat >/etc/pip.conf <<PIPCONF
[global]
index-url = #{$DEVPI_URL}
trusted-host = #{$DEVPI_SERVER}
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
