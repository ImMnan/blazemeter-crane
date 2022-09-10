#!/bin/bash

echo
echo "-------------------------------------------------------------------------------------------------------"
echo 

date | tee -a crane.log

sudo docker images | tee -a crane.log

sudo docker ps | tee -a crane.log

echo "[*] Copy the container ID of blazemeter-crane"

echo "[*] And enter the container id: "
read ID

sudo docker logs -f $ID | tee -a crane.log

