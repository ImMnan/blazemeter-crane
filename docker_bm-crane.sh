#!/bin/bash

echo "[*] This will install Fresh Docker into the ARM based system and get it ready to support AMD64 based docker images"

cat << EOF
[1] UBUNTU 20.04/22.04
[2] CentOS 7.7/7.8/7.9
[3] RHEL 7.7/7.8/7.9
[4] Debian 10
[5] Help

Select the OS of the machine emter the number:
EOF

while true
do
	echo "[*] !-NOTE-! Done installing docker then press c to continue or Ctrl+C to exit"
	read choice
	if [ $choice = "c" ]; then
    break

	elif [ $choice = "1" ]; then
		sudo apt-get remove docker docker-engine docker.io containerd runc
    echo "[*] Removed older version of Docker"
    sleep 1

    sudo apt update

    sudo apt install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release


    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "[*] Done adding GPG key"

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "[*] Repository settings made"

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[*] Latest Docker installation complete!"


  elif [ $choice = "2" ] || [ $choice = "3" ]; then
    sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
    echo "[*] Removed older version of Docker"

    sudo yum install -y yum-utils

    sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
    echo "[*] Installed the yum-utils package"

    sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[*] Latest Docker installation complete!"

  elif [ $choice = "4" ]; then
    sudo apt-get remove docker docker-engine docker.io containerd runc
    echo "[*] Removed older version of Docker"
    sleep 1

    sudo apt update

    sudo apt install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "[*] Done adding GPG key"

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "[*] Repository settings made"

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[*] Latest Docker installation complete!"

  elif [ $choice = "5" ]; then
    less README.md
    
  else
    echo "PLease enter a valid input!"
  fi

done


echo "[*] Are you using ARM system? (y for yes): "
read INPUT1

if [ $INPUT1 = 'y' ]; 
then
  echo "[*] Pulling and running AMD64 emulator"
  sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
  echo "[*] Docker is now ready to run AMD64 based containers"

elif [ $INPUT1 = 'yes' ]; 
then
  echo "[*] Pulling and running AMD64 emulator"
  sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
  echo "[*] Docker is now ready to run AMD64 based containers" 

else
  echo "[*] No need to setup AMD64 emulator, skipping the step"

fi 

echo "[*] Initiating Blaze-crane container now, please create an agent in Blaze, generate the docker command and enter the required field below,"

echo "[*] Enter the Harbor ID: "
read HARBOR_ID

echo "[*] Enter the Ship ID: "
read SHIP_ID

echo "[*] Enter the AUTH_TOKEN: "
read AUTH_TOKEN

sudo docker run --platform=linux/amd64 -d --env HARBOR_ID=$HARBOR_ID --env SHIP_ID=$SHIP_ID --env AUTH_TOKEN=$AUTH_TOKEN --env DOCKER_PORT_RANGE=6000-7000 -u 0 --name=bzm-crane-$SHIP_ID --restart=on-failure -v /var/run/docker.sock:/var/run/docker.sock -w /usr/src/app/ --net=host blazemeter/crane python agent/agent.py
sudo docker images
sudo docker ps

echo "You should be able to see Blazemeter crane container running! if you encounter an error, please contact support"

