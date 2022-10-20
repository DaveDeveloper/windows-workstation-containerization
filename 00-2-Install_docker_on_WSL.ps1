wsl sh -c "sudo apt install git"
wsl sh -c "./rundockerinstaller.sh"
wsl --shutdown
wsl sh -c 'sudo usermod -aG docker $USER'