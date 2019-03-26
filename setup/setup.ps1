#$ErrorActionPreference = "Stop"
$ErrorActionPreference = "SilentlyContinue"

Start-Process e:\setup64 -ArgumentList "/s /v `"/qb REBOOT=R`"" -Wait

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress "10.246.183.94" -PrefixLength 24 -DefaultGateway 10.246.183.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 172.20.4.13, 172.20.4.12

# Switch network connection to private mode
# Required for WinRM firewall rules
$profile = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private

# Enable WinRM service
Enable-PSRemoting -Force
winrm quickconfig -quiet
winrm quickconfig -transport:http
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

# WinRM Firewall Rules
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
netsh firewall add portopening TCP 5985 "Port 5985"

# WinRM restart
net stop winrm
net start winrm

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

#
# ONCE MORE
#

Start-Process e:\setup64 -ArgumentList "/s /v `"/qb REBOOT=R`"" -Wait

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress "10.246.183.94" -PrefixLength 24 -DefaultGateway 10.246.183.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 172.20.4.13, 172.20.4.12

# Switch network connection to private mode
# Required for WinRM firewall rules
$profile = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private

# Enable WinRM service
Enable-PSRemoting -Force
winrm quickconfig -quiet
winrm quickconfig -transport:http
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

# WinRM Firewall Rules
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes
netsh firewall add portopening TCP 5985 "Port 5985"

# WinRM restart
net stop winrm
net start winrm

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0
