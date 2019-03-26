# Teamcity with Azure agent vms on-demand
## Create teamcity
- create teamcity server from azure marketplace
![Screenshot](https://image.ibb.co/fmQ94d/teamcity0.png)
- Fill in all fields in template and login after creation
## Install clis
- create vm (I used redhat 7.5 distribution) in the teamcity resource group, install azure cli, packer and ansible.
```shell
sudo yum install unzip git -y
wget https://releases.hashicorp.com/packer/1.2.4/packer_1.2.4_linux_amd64.zip
unzip packer_1.2.4_linux_amd64.zip
sudo mv packer /usr/local/bin/
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install azure-cli ansible -y
```
## Configure Teamcity
- login to azure and get integration credentials
```bash
az login
az group create -n packer-resource-group -l eastus
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
az account show --query "{ subscription_id: id }"
```
- use values to configure cloud in http://**teamcity-url**/admin/editProject.html?projectId=_Root&tab=clouds
- additional ids should be obtained using this [instruction](https://blog.jetbrains.com/teamcity/2016/04/teamcity-azure-resource-manager/) in **Azure Authentication Settings** paragraph
- configure agent_preset for cloud vms in http://**teamcity-url**/agents.html?tab=agent.push. Leave Run agent under empty, its important due to "su: must be run from a terminal" error.
## Create managed image using packer and ansible
- Clone repository
```bash
git clone --single-branch --branch ubuntu-azure-arm https://github.com/ratanovvv/packer.git
cd packer
```
- Check symbolic links existence (lines with arrows)
```bash
ls -alth
```
- fill in **vars.json** and **ansible/roles/tc-builder/defaults/main.yml** with your values
- run packer (use -force to redefine managed image)
```bash
PACKER_LOG=1 packer build -force -var-file=vars.json ubuntu-mi.json
```
- get link to file from output
## Configure image in Teamcity
- Goto http://**teamcity-url**/admin/editProject.html?projectId=_Root&tab=clouds
- Add image to cloud profile
- set **Create public IP address** checkbox
- don't use special characters in prefix definition, excluding "**-**"
## Run build
Run job for docker to test image
