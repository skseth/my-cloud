# Manage your own CA

Adapted from : https://jamielinux.com/docs/openssl-certificate-authority/

## Creating a CA

To initialize your CA, run :

```Shell
./CA.sh <RootCAFolder>
```

The script creates a Root CA, and an intermediate CA.

Certificates are only issued via intermediate CA.

# Issuing Certificates

Run :

```Shell
./CA.sh <RootCAFolder> domainname outputdirectory

```

This will generate 2 files in the output directory :
<domainname>.cert.chained.pem
<domainname>.key.pem

Ensure key is kept confidential.

