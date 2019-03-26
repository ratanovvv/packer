# Microsoft Hyper-V template creation
## Prerequisites
- virtualization should be enabled in BIOS
- Windows 10 with Hyper-V component
- packer 1.2.5
- Pwershell (I used 5.1 version)
- Windows Linux Subsystem (WLS) installed (I used Debian)
- Ansible 2.4.2 installed on WLS
```shell
sudo apt-get update && sudo apt-get install -y python-pip
sudo pip install --upgrade pip
sudo pip install ansible==2.4.2
```
- Copy ansible.cmd and ansible-playbook.cmd to windows PATH environment variable. Or create new folder, copy there and add created location to PATH environment variable
- get Red Hat DVD, I used rhel-server-7.6-x86_64-dvd.iso from official redhat site
- copy setupVirtualSwitch.ps1 and run it in PowerShell. It will create 192.168.10.10 internal network. Feel free to change this to another values that don't cross your existing infrastructure
- open WLS and run (check ansible and remove hostkeys)
```bash
rm f ~/.ssh/known_hosts
ln -s /dev/null ~/.ssh/known_hosts
ansible --version
```
- open PowerShell as admin user and run
```powershell
$PSVersionTable
ansible --version
packer --version
```
## Configuration
### Get code
```bash
git clone --single-branch --branch rhel-hyperv-iso https://github.com/ratanovvv/packer.git
cd packer
```
### Configure vm settings
- fill in **rhel7hyperv_gen1.json** with your values
- define ip address in **rhel7hyperv_gen1.json**,**rhel7ks.cfg**,**inventory.yml**
- if you want to change root password you need to change it **in rhel7hyperv_gen1.json, rhel7ks.cfg, inventory.yml**
### Configure jaeger
- define proper environment variables for jaeger binaries in jaeger.yml
## Create template in Hyper-V
- Set value of "$env:USER" to your default user of Windows Linux Subsystem and run packer in PowerShell. 
```powershell
$env:USER = "default user for WLS"
packer build -force -var-file=rhel7vars.json .\rhel7hyperv_gen1.json
```
- **packer-demo** is the default name for template. It will be generated in current folder\output-hyperv-iso
## Jaeger services
- jaeger binaries are in `/usr/local/bin/`
- there are 4 jaeger systemd services
```
systemctl status jaeger-ingester jaeger-collector jaeger-agent jaeger-query
```
- configuration files with sample environment variables for each service
```
/etc/systemd/system/jaeger-ingester.service.d/override.conf
/etc/systemd/system/jaeger-collector.service.d/override.conf
/etc/systemd/system/jaeger-agent.service.d/override.conf
/etc/systemd/system/jaeger-query.service.d/override.conf
```
   - for new variables be applied execute
```
systemctl daemon-reload
```
- example: to start jaeger-collector execute
```
systemctl start jaeger-collector
```
- example: to view jaeger-collector logs run
```
journalctl -lu jaeger-collector
```
- example: to check jaeger-collector status execute
```
systemctl status jaeger-collector
```
- jaeger help
  - to see options for kafka backend `SPAN_STORAGE_TYPE=kafka /usr/local/bin/jaeger-collector help`
  - to see how to convert arguments to environment values `/usr/local/bin/jaeger-collector env`
