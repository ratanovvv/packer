### Versions
- vSphere 6.7
- Packer v1.3.4
- [packer-builder-vsphere-iso.linux v2.3](https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v2.3/packer-builder-vsphere-iso.linux)
- Windows System Image Manager(10.0.17763.1)
- VMware Tools 10.3.5
- Windows Server 2016 EVAL en-US image

### Upload images
- Upload win 2016 iso to vsphere datastore
- Upload vmware tools iso to vshere datastore
- Upload pvscsi-Windows8.flp floppy image to vsphere datastore

### vars.json
Set proper values for variables

### win2016.json
- Set path to win 2016 iso
- set path to pvscsi-Windows8.flp
- Set path to vmware tools iso
- Set hardware configuration

### setup/Autounattend.xml
- Install Windows System Image Manager (WSIM)
- Load Autounattend.xml to WSIM
- Load win 2016 iso to WSIM
- Change passwords for user in Autounattend.xml
- Change/Add any parameters in Autounattend.xml
- Save Autounattend.xml

### setup/setup.ps1
- Edit ip settings

### Run
```bash
PACKER_LOG=1 packer build -var-file=vars.json win2016.json
```
