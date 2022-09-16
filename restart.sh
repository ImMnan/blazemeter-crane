#!/bin/bash

sudo docker images
sudo docker ps -a
echo "[*] Enter the container ID for blazemeter-crane:"
read con_id

sudo docker stop $con_id
sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
sudo docker start $con_id

sudo docker ps

echo "[*] Make sure the container status is running and not restarting!"

