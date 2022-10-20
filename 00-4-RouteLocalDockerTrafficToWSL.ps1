# GET the current IP of the WSL
$wsl_ip = (wsl sh -c "hostname -I").Split(" ")[0]

# GET the IP of th WSL interface
$wsl_host_nic = Get-NetIPAddress -InterfaceAlias "vEthernet (WSL)" -AddressFamily IPv4
$wsl_host_ip = $wsl_host_nic.IPAddress
$wsl_host_prefix = $wsl_host_nic.PrefixLength

# since there is not a good way to assign static up to the WSL were are attaching the initial ip of WSL each time it restarts so the route rules on the host machine keeps working
wsl /bin/bash -c "echo 'ip addr change $wsl_ip/$wsl_host_prefix dev eth0' >> ~/.bashrc" 
echo 'nameserver DNSSERVER1\nnameserver DNSSERVER2\nnameserver DNSSERVER3' | sudo tee /etc/resolv.conf
wsl sh -c "echo 'nameserver DNSSERVER1\nnameserver DNSSERVER2\nnameserver DNSSERVER3' | sudo tee /etc/resolv.conf "


# GET network information of the LocalDevNet docker network bridge
$LocalDevNet_Subnet = (wsl sh -c "docker inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' LocalDevNet")
echo $LocalDevNet_Subnet
$LocalDevNet_Gateway = (wsl sh -c "docker inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' LocalDevNet")
echo $LocalDevNet_Gateway
$cmd = "ip addr  | grep {0}" -f $LocalDevNet_Gateway
$LocalDevNet_Interface = (wsl sh -c $cmd).Split(' ')[10]
echo $LocalDevNet_Interface

# Generate IP address to use for the DNS server
$octets = $LocalDevNet_Gateway -split "\."
$octets[3] = "254"
$dnsServerIP = $octets -join "."
echo $dnsServerIP;

# Enable network routing using iptables
wsl sh -c "sudo sysctl -w net.ipv4.ip_forward=1"
$cmd = "sudo iptables -t nat -A POSTROUTING -o {0} -j MASQUERADE"  -f $LocalDevNet_Interface
echo $cmd
wsl sh -c "$cmd"

#ADD route to the LocalDevNet on the host use the lower metric so that docker dns will be primary.
New-NetRoute -DestinationPrefix "$LocalDevNet_Subnet" -InterfaceAlias "vEthernet (WSL)"  -NextHop $wsl_ip -RouteMetric 12

#SET dns servers on the WSL interface
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (WSL)" -ServerAddresses ($dnsServerIP,"DNSSERVER1","DNSSERVER2","DNSSERVER3")


#Disable WSL generating host and resolve file
wsl sh -c "echo '[network]\ngenerateHosts = false\ngenerateResolvConf = false' | sudo tee /etc/wsl.conf"

#SET dns on the ubuntu machine
wsl sh -c "echo 'nameserver DNSSERVER1\nnameserver DNSSERVER2\nnameserver DNSSERVER3' | sudo tee /etc/resolv.conf "

# Need to generalize DNS IPs.