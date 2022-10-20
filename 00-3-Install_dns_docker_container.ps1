$Folder = 'c:\docker\dnsmasq-rest-api-docker'
if (Test-Path -Path $Folder) {
	echo "repo already exists"
	git pull $Folder
} else {
	mkdir c:\docker
	git clone https://github.com/DaveDeveloper/dnsmasq-rest-api-docker $Folder
}


# create LocalDevNet
# need to make this generic

wsl sh -c "docker network create LocalDevNet --subnet=172.27.0.0/16 --gateway=172.27.0.1"

$LocalDevNet_Gateway = (wsl sh -c "docker inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' LocalDevNet")
$octets = $LocalDevNet_Gateway -split "\."
$octets[3] = "254"
$dnsServerIP = $octets -join "."
echo $dnsServerIP;

(Get-Content -path $Folder\docker-compose.yml -Raw) -replace '172.27.0.254',$dnsServerIP | Set-Content -Path $Folder\docker-compose.ymls

wsl --cd "c:\docker\dnsmasq-rest-api-docker" sh -c " docker-compose up -d"
