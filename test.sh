#!/bin/sh

echo "[*] Are you using ARM system? (y or n): "
read INPUT1

for (( ; ; )); 
do
  if [ $INPUT1 = 'y' ]; 
  then
    echo "[*] Pulling and running AMD64 emulator"
    #sudo docker run --privileged --rm tonistiigi/binfmt --install amd64
    echo "[*] Docker is now ready to run AMD64 based containers"
    break
  
  elif [ $INPUT1 = 'n' ]; 
  then
    echo "[*] No need to setup AMD64 emulator, skipping the step"  
    break
  
  else
    echo "Please enter a valid response! (y or n)"

 fi 
 
done 
