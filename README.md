# Windows workstation containerization

## Introduction
This project is focused on providing a seamless integrations of docker containers in to the development environments.

Lets say that you have an application stack with a Database Server that is hosted in a central servers. and your application is connecting to it using a dns resolve-able hostname.

You want to run a local copy of the database on a docker instance. But that would mean that you will have to change your application to connect to that docker instance.

This project allows you to create a docker instance with specific labels. When instance is started the DNS hostname(s) associated with that docker instance is over taken to route to the docker instance. When that instance is stopped the DNS hostname(s) are reverted to point to the default location. 


## Installation
Run following on PowerShell Terminal as administrator
> git clone https://github.com/DaveDeveloper/windows-workstation-containerization.git

> cd windows-workstation-containerization

### Run following commands
Install WSL and ubuntu 20.04  with proper permissions
>.\00-1-INSTALL_ubuntu_WSL_and_allow_default_user_to_sudo_without_password.ps1

Install Docker and ensure it auto starts
>.\00-2-Install_docker_on_WSL.ps1

Install dnsmasq-rest-api-docker container with docker event watcher
>.\00-3-Install_dns_docker_container.ps1

Properly route traffic and DNS request to the dnsmasq-rest-api-docker instance
>.\00-4-RouteLocalDockerTrafficToWSL.ps1

Note: Not perfectly working yet. Needs some manual seting up.
