# my-cloud
Setup cloud on local machine using vagrant, docker, coreos and other tools

The cloud will have

- dns server
- will use self-signed wild-card certificates (one per project)

## Vagrant - Create my own box

From https://scotch.io/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one, with adaptations.

##Create virtual machine using vagrant file provided in my-vagrant-box
This uses ubuntu trusty

vagrant up
vagrant ssh

##Fix locale issue from Client SSH

When you do vagrant ssh, you will see an error - this is because your client SSH machine is sending a locale not present of server, usually UTF-8, and the /etc/ssh/sshd_config has the setting : AcceptEnv LANG LC_*

You can fix this by (depending on the message) :

sudo locale-gen UTF-8

##apt-get
as root :
MAY not need step to install build-essential, module-assistant
```
apt-get update
apt-get upgrade
apt-get install build-essential module-assistant
```

##Virtual Box Guest Additions

###Copy VirtualBoxGuestAdditions ISO to guest :

on host (e.g. mac)

```
cp /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso .
```


###Cleaning up pre-installed VirtualBox Guest Additions 

Needed if guest editions have been pre-installed in box

```Shell
apt-get list | grep virtualbox
apt-get remove virtualbox-guest-utils
apt-get remove virtualbox-guest-x11
etc.
```
Do further cleanup
https://forums.virtualbox.org/viewtopic.php?t=7839
Not all of the below may be needed

Step 1: Remove kernel modules

Do 

```
find /lib/modules -name "*vbox*"
```

If you find modules (e.g. vboxsf.ko, vboxvideo.ko, vboxguest.ko), you should run :

apt-get remove virtualbox-guest-dkms

Step 2 : remove virtual box guest utils

apt-get remove virtualbox-guest-utils

You will find files in /usr/src/VirtualBox... will be removed.

Step 3 : Remove leftover files 

```Shell
sudo find /etc -name "*vboxadd*" -exec rm {} \;
sudo find /etc -name "*vboxvfs*" -exec rm {} \;
```

A little explanation: 
1. All vboxadd* entries belongs to Guest Additions 
2. All vboxvfs* entries are related to Shared Folder feature which is also part of Guest Additions


###update vbox guest additions 
(see https://gist.github.com/fernandoaleman/5083680)
as root, run :

```Shell
mount VBoxGuestAdditions.iso -o loop /mnt
cd /mnt
sh VBoxLinuxAdditions.run --nox11
```Shell

# Now check that the Guest Additions work
$ vagrant halt
$ vagrant up

# Do final cleanup

sudo apt-get clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY

# Package the new VM
$ vagrant halt
$ vagrant package --output my-trusty.box



##local dns server

Convention followed :

use domain .$(whoami) for local servers
use subdomain <project>.$(whoami) for each project
create wild-card self-signed certificate for each subdomain

For shared dev infrastructure, you may want to use a dev-level dns server. 

Suggested Convention :
use subdomain <project>.dev for each project
create wild-card self-signed certificate for <project>.dev

Use dnsmasq to setup local dns.

Best to setup on host, so it is always up and reachable from all guests and does not disappear if you destroy a container.

References :

[jed - how to set up stress free ssl on os x](https://gist.github.com/jed/6147872)

[dnsmasq for easy lan name services](https://www.linux.com/learn/tutorials/516220-dnsmasq-for-easy-lan-name-services)


##load balancer

##docker registry


##mail server



##mitmproxy


##logging, monitoring
- logstash
- kibana
- graphite


##dev env
- ci server




