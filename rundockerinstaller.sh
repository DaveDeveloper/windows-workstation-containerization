dockercompoasepath=`which docker-compose`

if [ ! -f "$dockercompoasepath" ]; then
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt-get install \
	    ca-certificates \
	    curl \
	    gnupg \
	    lsb-release \
	    jq

	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	sudo apt-get update -y
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

bashrcfile=~/.bashrc;
if ! grep -q "dockerd" $bashrcfile; then
	echo '# Start Docker daemon automatically when logging in if not running.' >> $bashrcfile
	echo 'RUNNING=`ps aux | grep dockerd | grep -v grep`' >> $bashrcfile
	echo 'if [ -z "$RUNNING" ]; then' >> $bashrcfile
	echo '    sudo dockerd > /dev/null 2>&1 &' >> $bashrcfile
	echo '    disown' >> $bashrcfile
	echo 'fi' >> $bashrcfile
fi
if ! grep -q "dockerlistener" "$bashrcfile"; then
	sudo cp ./dockerlistener.sh /usr/bin/dockerlistener.sh
	sudo chown root.root /usr/bin/dockerlistener.sh

	echo '# Start dockerlistener daemon automatically when logging in if not running.' >> $bashrcfile
	echo 'pgrep -x dockerlisten >/dev/null && RUNNINGx=true || RUNNINGx=false' >> $bashrcfile
	echo 'if [ !$RUNNINGx ]; then' >> $bashrcfile
	echo '    sudo /usr/bin/dockerlistener.sh > /dev/null 2>&1 &' >> $bashrcfile
	echo '    disown' >> $bashrcfile
	echo 'fi' >> $bashrcfile
fi