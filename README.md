# devstack-vagrant

This is a simple Vagrant setup for devstack based on fedora.

## Vagrant installation

Make sure you have a current version of vagrant installed. In case of Linux make sure you have the vagrant-libvirt provider installed as well. For fedora 22 there is a nice article here:

http://fedoramagazine.org/running-vagrant-fedora-22/

Especially make sure, NFS-based shared folders are working as explained here:

http://nts.strzibny.name/vagrant-nfs-exports-on-fedora-21/

## Starting devstack VM

It's very simple:

```$ vagrant up```

After a while (around 10 minutes) you have an openstack runnig, and you can access the web-interface at http://localhost:8080/

## Configuration

If you wanna customize your configuration, copy `config.yaml.sample` to `config.yaml` end edit accordingly.

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

`devpi_server`, `devpi_port`, `devpi_path` - You can easily setup a cache for the pip repository with `devpi-server`. Just do 
```
$ pip install --user devpi-server
$ devpi-server --start --host=0.0.0.0
```
and uncomment these settings in `config.yaml`. You also have to change `devpi_server` to one of your local IPs.
