### Choose template

There are two templates.
One with hetwork enabled and one without any - **dhcp** and **local** directories.
The one with network is prefered, because vm-tools are installed and ssh is enabled already.
To install with network you need distributed portgroup with ephemeral port binding.
Otherwise there will be no carrier on interface.

### SSH Private Key

Clone.
Provide **id_rsa** private key.
```sh
[user@cli_rvv ws]$ git clone ssh://git@bitbucket-dirpp.sibintek.ru:7999/dev/packer.git
[user@cli_rvv ws]$ cd packer/dhcp
[user@cli_rvv dhcp]$ cp /path/to/private/key/id_rsa ./
```

### centos7ks.json

Customize ssh rsa public key and passwords in **centos7ks.json**.
To encrypt passwords use this command:
```sh
[user@cli_rvv dhcp]$ python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
```


### vars.json

customize **vars.json** file with appropriate vcenter credentials and ssh username

### Run

Deploy template with packer

```sh
[user@cli_rvv dhcp]$ PACKER_LOG=1 packer build -var-file=vars.json centos7.json
```