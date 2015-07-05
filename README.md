# my-cloud
Setup cloud on local machine using vagrant, docker, coreos and other tools

The cloud will have

- dns server
- will use self-signed wild-card certificates (one per project)

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

##self-cert
Inspired by https://gist.github.com/jed/6147872
Script to create self signed certificate using openssl

Status : tested only on os-x mavericks




