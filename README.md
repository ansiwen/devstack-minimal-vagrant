# devstack-vagrant

This is a simple Vagrant setup for DevStack based on Fedora.

## Vagrant installation

Make sure you have a current version of Vagrant installed. In case of Linux make sure you have the vagrant-libvirt provider installed as well. For Fedora 22 there is a nice article here:

http://fedoramagazine.org/running-vagrant-fedora-22/

Especially make sure, NFS-based shared folders are working as explained here:

http://nts.strzibny.name/vagrant-nfs-exports-on-fedora-21/

## Starting DevStack VM

It's very simple:

```$ vagrant up```

After a while (around 20-30 minutes initially, 10 minutes subsequently) you have an OpenStack runnig, and you can access the web-interface at http://localhost:8080/

With `vagrant ssh` you can log into the VM.

In your current directory there will be a folder `openstack`, which contains the openstack source code and is shared with the devstack VM.

Inside of the VM you find the shared openstack sources in `/vagrant/openstack` and the data in `/var/openstack`.

In the `.wheelhouse` directory (not to confuse with `openstack/.wheelhouse` of former DevStacks) you can find all wheels, that had been created while running stack.sh and which will be used tp speed up subsequent builds. This also can be very useful for running unit tests on the host, which is a lot faster because of faster file access.

## Configuration

If you wanna customize your configuration, copy `config.yaml.sample` to `config.yaml` and edit accordingly.

`local_conf` - set it to your own local.conf file for devstack configuration.

`local_git_repos` - if you have your own local git repository (maybe with you own working branches) of all the relevant openstack.org repos, set the path to it here.

`http_proxy` - although most necessary packages are already pre-installed in the base image, you can use a local caching http proxy to speed up the devstack setup procedure by setting a local proxy url. To set one up on fedora, just do: 
```
$ sudo dnf install squid
```

Edit `/etc/squid/squid.conf` and add the lines
```
cache_dir ufs /var/spool/squid 10000 16 256
maximum_object_size 128 MB
```

Start it with
```
$ sudo systemctl enable squid
$ sudo systemctl restart squid
```

`yum_repo` - if you use a caching proxy, you should also select a specific fedora repository mirror, that is caching friendly. This you can do here.

`devpi_server`, `devpi_port`, `devpi_path` - Although most wheels are stored under `.wheelhouse`, it can still be useful to have a local pip cache. You can easily setup a cache for the pip repository with `devpi-server`. Just do 
```
$ pip install --user devpi-server
$ devpi-server --start --host=0.0.0.0
```
and uncomment these settings in `config.yaml`. You also have to change `devpi_server` to one of your local IPs.

## Caveats

Doing the unit-tests from inside the VM with the NFS mounted sources is quite slow. Therefore I run them from the host with the `PIP_FIND_LINKS` environment variable set accordingly to the .wheelhouse directory, so you don't have to spoil your system with all the requirements. (venv doesn't really seem to help here, since there are native libraries involved.)

## TODOs

* make it work with lxc containers, which would allow a lot more efficient bind mounts for the shared folder.
* extend it to multi-node setups.
