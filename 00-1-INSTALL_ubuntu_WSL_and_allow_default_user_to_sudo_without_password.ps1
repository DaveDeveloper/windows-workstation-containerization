# Enable VirtualMachinePlatform if needed
$vmpEnabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform |  Select-Object -Property State
if ( $vmpEnabled -like "*Enabled*" ) {
	echo "VirtualMachinePlatform Alredy Installed"
} else {
	Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
}

# Enable Microsoft-Windows-Subsystem-Linux if needed
$linuxSubSysEnabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux |  Select-Object -Property State
if ( $linuxSubSysEnabled -like "*Enabled*" ) {
	echo "Linux Subsystem Alredy Installed"
} else {
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

#check to see if wsl2 is enabled
$windosbuild = [System.Environment]::OSVersion.Version |Select-Object -Property Build
if ($windosbuild.Build -gt 18916) {
	echo "WSL version supported is 2 ";
	wsl --set-default-version 2
} else {
	Start-BitsTransfer -Source "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/updt/2022/03/wsl_update_x64_8b248da7042adb19e7c5100712ecb5e509b3ab5f.cab" -Destination "wsl_update_x64.cab"
	cmd.exe /c "C:\Windows\System32\expand.exe wsl_update_x64.cab wsl_update_x64.msi"
	msiexec.exe /I wsl_update_x64.msi /quiet
	wsl --set-default-version 2
}

# Install Ubuntu-20.04 if needed
$wsl_info = ( wsl.exe -l -v)
## This detection is not quite working. need to fix
## if ($wsl_info -like "*Ubuntu-20.04*") {
if ($false) {	
	echo "Ubuntu-20.04 is already installed";
} else {
	#install Ubuntu 20.04
	wsl --install -d Ubuntu-20.04
	wsl --set-version Ubuntu-20.04 2
	#set ubuntu 20.04 as default
	wsl --setdefault Ubuntu-20.04
}


#check to see if wsl2 is enabled
if ($wsl_info -contains "Ubuntu-20.04") {
	echo "Ubuntu-20.04 is already installed";
} else {
	Start-BitsTransfer -Source "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/updt/2022/03/wsl_update_x64_8b248da7042adb19e7c5100712ecb5e509b3ab5f.cab" -Destination "wsl_update_x64.cab"
	cmd.exe /c "C:\Windows\System32\expand.exe wsl_update_x64.cab wsl_update_x64.msi"
	msiexec.exe /I wsl_update_x64.msi /quiet
}


#allow the default user to run sudo without password
$wsl_user = (wsl sh -c "whoami")
echo $wsl_user

$cmd = "echo '{0} ALL=(ALL:ALL) NOPASSWD: ALL' >>  /etc/sudoers.d/wsluser"  -f $wsl_user

echo $cmd

wsl -u root sh -c $cmd