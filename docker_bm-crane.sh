#!/bin/bash

echo "[*] This will install Fresh Docker into the ARM based system and get it ready to support AMD64 based docker images"
sleep 2

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
echo "[*] Docker installation complete!"

echo "[*] Are you using ARM system? (y or n): "
read INPUT1

if [ $INPUT1 = 'y' ]; 
then
  echo "[*] Pulling and running AMD64 emulator"
  sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
  echo "[*] Docker is now ready to run AMD64 based containers"
elif [ $INPUT1 = 'n' ]; 
then
  echo "[*] No need to setup AMD64 emulator, skipping the step"  
sleep 1
else
  echo "Please enter a valid response! (y or n)"

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

