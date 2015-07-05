
##Installing dnsmasq on os x

brew install dnsmasq

##Configuring 

###Create dnsmasq.conf
Edit dnsmasq.conf to add your address entries.

cp ./dnsmasq.conf /usr/local/etc/dnsmasq.conf

###Setup dnsmasq daemon

```Shell
sudo cp $(brew list dnsmasq | grep /homebrew.mxcl.dnsmasq.plist$) /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
```

###Restarting dnsmasq

Needed if you edit dnsmasq.conf

```Shell
sudo launchctl stop homebrew.mxcl.dnsmasq
```


##References
[dnsmasq on os x](http://passingcuriosity.com/2013/dnsmasq-dev-osx/)
[dnsmasq for easy lan services](https://www.linux.com/learn/tutorials/516220-dnsmasq-for-easy-lan-name-services)
[Simple way to run dnsmasq with VirtualBox on host-only interfaces](https://ramonnogueira.wordpress.com/2013/03/29/simple-way-to-run-dnsmasq-for-virtualbox-guest-dhcp/)