# the name of our internal vSwitch.  This needs to match what we configure below in the packer.json
$VS = "internal_vSwitch"

# create the virtual swithc
New-VMSwitch -SwitchName $VS -SwitchType Internal

# get the interface index and then set the IP / netmask
$IF_INDEX = (Get-NetAdapter -Name "vEthernet ($VS)").ifIndex
New-NetIPAddress -IPAddress 192.168.10.1  -PrefixLength 24 -InterfaceIndex $IF_INDEX

# now that the interface is configured, let's add a virtual NAT.
# this is what allows our guest VM, also configured on the 192.168.10.0/24 net to route out and download packages.
New-NetNat -Name "internal_vNAT" -InternalIPInterfaceAddressPrefix 192.168.10.0/24