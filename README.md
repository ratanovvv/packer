# Prerequisites
- Use [this instruction](https://nickcharlton.net/posts/using-packer-esxi-6.html) to build on esxi host. Duplicate is below.
## Configuring the ESXi Host
Our ESXi host needs a little bit of configuration to allow Packer to work. Packer communicates over SSH, so first we need to open that. Secondly, we’ll enable an option to discover Guest IPs from the Host and then finally allow VNC connections remotely.
### Enable SSH
Inside the web UI, navigate to "Manage", then the "Services" tab. Find the entry called: "TSM-SSH", and enable it.

You may wish to enable it to start up with the host by default. You can do this inside the "Actions" dropdown (it's nested inside "Policy").
### Enable "Guest IP Hack"
Run the following command on the ESXi host:
`esxcli system settings advanced set -o /Net/GuestIPHack -i 1`
This allows Packer to infer the guest IP from ESXi, without the VM needing to report it itself.
### Open VNC Ports on the Firewall
Packer connects to the VM using VNC, so we'll [open a range of ports](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2008226) to allow it to connect to it.

First, ensure we can edit the firewall configuration:
```bash
chmod 644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
```
Then append the range we want to open to the end of the file:
```xml
<service id="1000">
  <id>packer-vnc</id>
  <rule id="0000">
    <direction>inbound</direction>
    <protocol>tcp</protocol>
    <porttype>dst</porttype>
    <port>
      <begin>5900</begin>
      <end>6000</end>
    </port>
  </rule>
  <enabled>true</enabled>
  <required>true</required>
</service>
```
Finally, restore the permissions and reload the firewall:
```bash
chmod 444 /etc/vmware/firewall/service.xml
esxcli network firewall refresh
```

# Create Packer template

### Choose template

There are two templates.
One with hetwork enabled and one without any - **dhcp** and **local** directories.
The one with network is prefered, because vm-tools are installed and ssh is enabled already.
To install with network you need distributed portgroup with ephemeral port binding.
Otherwise there will be no carrier on interface.

### SSH Private Key

Clone.
Provide **id_rsa** private key.
```bash
git clone --single-branch --branch centos-vmware-iso https://github.com/ratanovvv/packer.git
cd packer/dhcp
cp /path/to/private/key/id_rsa ./
```

### centos7ks.json

Customize ssh rsa public key and passwords in **centos7ks.json**.
I used password "password". To encrypt passwords use this command:
```bash
python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
```


### vars.json

customize **vars.json** file with appropriate vcenter credentials and ssh username

### Run

Deploy template with packer

```bash
PACKER_LOG=1 packer build -var-file=vars.json centos7.json
```
