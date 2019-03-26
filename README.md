# VmWare vSphere template creation
## Prerequisites
- create vm (I used centos 7.5 distribution) in VmWare vSphere (I used vSphere 6.7 distribution).
- install clis
```shell
yum install -y epel-release
yum install wget unzip git python-pip -y
wget https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
unzip packer_1.3.2_linux_amd64.zip
mv packer /usr/local/bin/
wget https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v2.0.1/packer-builder-vsphere-iso.linux
chmod +x packer-builder-vsphere-iso.linux
pip install --upgrade pip
pip install ansible==2.4.2
```
- upload Red Hat DVD to datastore in vSphere
## Configuration
### Get code
```bash
git clone --single-branch --branch rhel-vsphere-iso https://github.com/ratanovvv/packer.git
cd packer
```
### Configure vm settings
- fill in **rhel7vars.json** with your values
- define ip address in **rhel7ks.cfg**
- (advanced) if you want to change root password you need to change it **both in rhel7vsphere.json and rhel7ks.cfg**
- (advanced) change values in **rhel7vsphere.json**
### Configure jaeger
- define proper environment variables for jaeger binaries in jaeger.yml
## Create template in vSphere
- run packer
```
PACKER_LOG=1 packer build -force -var-file=rhel7vars.json rhel7vsphere.json
```
- **rhel7jaeger** is the default name for template
## (Optional) Export to ovf
- Change "convert_to_template" to "false" in rhel7vsphere.json
- export to ovf from rhel7jaeger vm
![vSphere UI](https://github.com/ratanovvv/packer.git)
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

