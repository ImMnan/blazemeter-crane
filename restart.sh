#!/bin/bash

service docker status

echo "Making sure the docker is running"

sudo docker run --privileged --rm tonistiigi/binfmt --install amd64

sudo docker ps -a
echo "Enter the container ID for blazemeter-crane: "
read con_id

sudo docker ps stop $con_id
sudo docker ps start $con_id

sudo docker ps

echo "Make sure the container status is running and not restarting!"

