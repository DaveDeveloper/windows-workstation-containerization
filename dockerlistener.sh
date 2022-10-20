#!/bin/bash
sleep 15;
update_dns() {
        containerID=$(echo $line | cut -d " " -f 4|tr -dc '[:alnum:][:punct:]')
        case $action in
                "start" )
                containerIP=$(docker inspect $containerID | jq '.[].NetworkSettings.Networks.LocalDevNet.IPAddress')
                ;;
        esac

        for args in ${line}
        do
                if [[ $args == *"localdev"* ]]
                then
                        echo $args
                        hostname=$(echo $args |  cut -d"=" -f 2 | cut -d"," -f 1)

                        case $action in
                                "start" )
                                printf -v url "http://localhost:5380/dnsmasq-rest-api/zones/myZone/%s/%s" $containerIP $hostname
                                curl -X POST $url
                                ;;
                                "stop" )
                                containerIP=$(dig +short $hostname @localhost)
                                printf -v url "http://localhost:5380/dnsmasq-rest-api/zones/myZone/%s/%s" $containerIP $hostname
                                curl -X DELETE $url
                                ;;
                        esac
                fi
        done
        curl -X POST http://localhost:5380/dnsmasq-rest-api/reload
}
docker events |  while read line
do
        if [[ $line == *" start "* ]]
        then
                action="start"
                update_dns
        elif [[ $line == *" stop "* ]]; then

                action="stop"
                update_dns
        fi