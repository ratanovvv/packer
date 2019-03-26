# Teamcity with Azure agent vms on-demand
## Install clis
- create vm (I used redhat/centos 7.5 distribution) in the teamcity resource group, install azure cli, packer and ansible.
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
```
az login
az group create -n tf-resource-group -l eastus
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
az account show --query "{ subscription_id: id }"
```
- use values to configure cloud in http://**teamcity-url**/admin/editProject.html?projectId=_Root&tab=clouds
- additional ids should be obtained using this [instruction](https://blog.jetbrains.com/teamcity/2016/04/teamcity-azure-resource-manager/) in **Azure Authentication Settings** paragraph
- configure agent_preset for cloud vms in http://**teamcity-url**/agents.html?tab=agent.push. Leave Run agent under empty, its important due to "su: must be run from a terminal" error.

##  Create vhd using packer and ansible
### Windows vhd
- Install required packages
```bash
sudo yum install -y epel-release
sudo yum groupinstall "Development tools"
sudo yum install -y python-pip
sudo pip install --upgrade pip
sudo pip install pywinrm
sudo pip install pywinrm[kerberos]
sudo pip install pywinrm[credssp]
```
- Get azure serviceprincipal object_id
```bash
az ad sp create-for-rbac --role="Contributor" \
--scopes="/subscriptions/<YOUR-SUBSCRIPTION_ID>"
az ad sp show --id "<APP-ID-OUTPUT-FROM-PREVIOUS-COMMAND>"
```
- Use in **vars.json** object_id from output
- Clone repository
```bash
git clone --single-branch --branch win2016-azure-arm https://github.com/ratanovvv/packer.git
```
- fill in **vars.json**
- change user/pass for windows server in **tc-builder.yml**
- run packer (use -force to redefine managed image)
```bash
PACKER_LOG=1 packer build -force -var-file=vars.json win2016-mi.json
```
- get link to file from output

### Linux managed image
- Clone repository
```bash
git clone --single-branch --branch ubuntu-azure-arm https://github.com/ratanovvv/packer.git
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

## Configure Teamcity Server
> TeamCity provides functionality that allows installing a build agent to a remote host. Currently supported combinations of the server host platform and targets for build agents are:
> 
> from the Unix-based TeamCity server, build agents can be installed to Unix hosts only (via SSH).
> 
> from the Windows-based TeamCity server, build agents can be installed to Unix (via SSH) or Windows (via psexec) hosts.

- Sysinternals psexec can be installed in Administration -> Tools
- Teamcity server windows service must be running under account with network access (not default LocalService). Otherwise psexec won't work
- Use dns name instead of ip in teamcity global configuration. You can use dynamic external ips and not pay for static ip reservation

## Known Issues
- JDK8 Installation may fail becuase of remote server availability. Run deployment again on error.
```text
    azure-arm:     "stdout_lines": [
    azure-arm:         "Installing the following packages:",
2018/06/27 14:54:28 ui:     azure-arm:     "stdout_lines": [
2018/06/27 14:54:28 ui:     azure-arm:         "Installing the following packages:",
    azure-arm:         "jdk8",
    azure-arm:         "By installing you accept licenses for the packages.",
2018/06/27 14:54:28 ui:     azure-arm:         "jdk8",
2018/06/27 14:54:28 ui:     azure-arm:         "By installing you accept licenses for the packages.",
    azure-arm:         "jdk8 not installed. An error occurred during installation:",
    azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out",
    azure-arm:         "jdk8 package files install completed. Performing other installation steps.",
2018/06/27 14:54:28 ui:     azure-arm:         "jdk8 not installed. An error occurred during installation:",
2018/06/27 14:54:28 ui:     azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out",
2018/06/27 14:54:28 ui:     azure-arm:         "jdk8 package files install completed. Performing other installation steps.",
2018/06/27 14:54:28 ui:     azure-arm:         "The install of jdk8 was NOT successful.",
2018/06/27 14:54:28 ui:     azure-arm:         "jdk8 not installed. An error occurred during installation:",
2018/06/27 14:54:28 ui:     azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out",
2018/06/27 14:54:28 ui:     azure-arm:         "",
2018/06/27 14:54:28 ui:     azure-arm:         "Chocolatey installed 0/1 packages. 1 packages failed.",
2018/06/27 14:54:28 ui:     azure-arm:         " See the log for details (C:\\ProgramData\\chocolatey\\logs\\chocolatey.log).",
2018/06/27 14:54:28 ui:     azure-arm:         "",
2018/06/27 14:54:28 ui:     azure-arm:         "Failures",
2018/06/27 14:54:28 ui:     azure-arm:         " - jdk8 (exited 1) - jdk8 not installed. An error occurred during installation:",
2018/06/27 14:54:28 ui:     azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out"
2018/06/27 14:54:28 ui:     azure-arm:     ]
2018/06/27 14:54:28 ui:     azure-arm: }
    azure-arm:         "The install of jdk8 was NOT successful.",
    azure-arm:         "jdk8 not installed. An error occurred during installation:",
    azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out",
    azure-arm:         "",
    azure-arm:         "Chocolatey installed 0/1 packages. 1 packages failed.",
    azure-arm:         " See the log for details (C:\\ProgramData\\chocolatey\\logs\\chocolatey.log).",
    azure-arm:         "",
    azure-arm:         "Failures",
    azure-arm:         " - jdk8 (exited 1) - jdk8 not installed. An error occurred during installation:",
    azure-arm:         " The remote server returned an error: (524) Origin Time-out. Origin Time-out"
    azure-arm:     ]
    azure-arm: }
```
