#!/bin/bash
echo
echo

date >> crane.log

sudo docker images >> crane.log

sudo docker ps -a >> crane.log

sudo docker ps
echo "Copy the container ID of blazemeter-crane"

echo "And enter the container id: "
read ID

sudo docker logs -f $ID >> crane.log

