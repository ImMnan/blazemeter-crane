#!/usr/bin/env bash

# Checks if user is root
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[31mYou must run this script as root"
  echo -e "\e[39m"
  exit 1
fi

# This script checks that all the Private Location requirements have been met

echo "Starting requirements check..."
echo

# OS Distribution and Version check
distribution=$(cat /etc/os-release | grep "NAME" | head -1 | cut -d '"' -f 2)
version=$(cat /etc/os-release | grep 'VERSION=' | head -1 | tr ' ' '\n' | grep '[0-9]' | cut -d '"' -f 2)

# Current supported versions for various distros
supported_centos=("7" "7.1" "7.2" "7.3" "7.4" "7.5" "7.6" "7.7" "7.8" "7.9")
supported_ubuntu=("12.04" "14.04" "16.04" "18.04" "20.04" "22.04")
supported_debian=("9" "10")

# Check for whether a version exists or not
is_centos=false
version_check=false
firewall_check=false
selinux_check=false
mem_check=false
cpu_check=false
hard_drive_check=false
docker_check=false
connectivity_check=false

# Check for CentOS versions
if [[ $distribution == *"CentOS"* || $distribution == *"Red Hat"* ]]
then
  selinux=$(sestatus | grep "SELinux status" | cut -d ":" -f 2 | tr ' ' '\n' | grep "enabled")
  firewall=$(sudo firewall-cmd --state > /dev/null 2>&1)
  
  # Check is SELinux is enabled
  if [[ $selinux == "enabled" ]]
  then
    echo -e "\e[33mSelinux is enabled and may cause issues with BlazeMeter agents."
  else
    echo -e "\e[32mSelinux is disabled."
    selinux_check=true
  fi

  # Check if firewall is running
  if [[ $firewall == "running" ]]
  then
    echo -e "\e[33mFirewall is enabled and may cause issues with BlazeMeter agents if not properly configured."
  else
    echo -e "\e[32mFirewall is disabled."
    firewall_check=true
  fi

  # Check the version of RedHat/CentOS against supported versions
  for i in "${supported_centos[@]}"
  do
    if [[ $i == $version ]]
    then
      version_check=true
      break
    fi
  done
  is_centos=true
# Check for Ubuntu versions
elif [[ $distribution == *"Ubuntu"* ]]
then
  ubuntu_version=$(echo $version | cut -b 1-5)
  # Check the version of Ubuntu against supported versions
  for i in "${supported_ubuntu[@]}"
  do
    if [[ $i == $ubuntu_version ]]
    then
      version_check=true
      break
    fi
  done

# Check for Debian versions
elif [[ $distribution == *"Debian"* ]]
then
  # Check the version of Debian against supported versions
  for i in "${supported_debian[@]}"
  do
    if [[ $i == $version ]]
    then
      version_check=true
      break
    fi
  done
fi

# Notifies if version is supported or not
if [[ $version_check == false ]]
then
  echo -e "\e[31mVersion $version of $distribution is not supported."
else
  echo -e "\e[32mVersion $version of $distribution is supported."
fi

# Commands to check the memory, cpu, and hard_drive available on the machine
memory=$(expr $(cat /proc/meminfo | grep MemTotal | awk {'print $2'}) \/ 1024)
cpu=$(grep -c processor /proc/cpuinfo)
hard_drive=$(expr $(df -h | grep '^/dev' | grep '[0-9]G' | grep '/$' | awk '{print $2}' | cut -d 'G' -f 1))

# Verifies if RAM meets the 8 GB requirement
if [ $memory -gt 7800 ]
then
  echo -e "\e[32mYour $memory MB of RAM meets the requirements."
  mem_check=true
else
  echo -e "\e[31mYour $memory MB of RAM does not meet the requirements. Make sure you have atleast 8GB or more installed!"
fi

# Verifies the number of CPU cores is 2 or greater
if [[ $cpu >= 2 ]]
then
  echo -e "\e[32mYour $cpu cores meets the requirements."
  cpu_check=true
else
  echo -e "\e[31mYour $cpu cores does not meet the requirements. Processor must be atleast dual core."
  echo "[*]!-note-! If your architechture is ARM, make sure to choose it while running docker_bm-crane.sh as Blazemeter-crane image is based on AMD64 architechture"
fi

# Verifies the size of the hard drive meets the 100 GB requirement
if [ $hard_drive -gt 99 ]
then
  echo -e "\e[32mYour $hard_drive GB disk space meets the requirements."
  hard_drive_check=true
else
  echo -e "\e[31mYour $hard_drive GB disk space does not meet the requirements."
fi

# Check for if Docker is installed
if ! command -v docker &> /dev/null
then
  echo -e "\e[31mThe docker command could not be found."
else
  # If Docker exists, check its version
  docker=$(sudo docker -v | awk '{print $3}' | cut -d ',' -f 1 | cut -d '.' -f 1)
  version=$(sudo docker -v | awk '{print $3}' | cut -d ',' -f 1)

  if [[ $docker > 16 ]]
  then
    echo -e "\e[32mYour Docker version $version is supported."
    docker_check=true
  else
    echo -e "\e[31mYour Docker version $version is not supported."
  fi
fi

# Commands to check connectivity to the various URLs used in BlazeMeter
performance=$(curl -s https://a.blazemeter.com/api/v4/user | grep "code" | awk '{print $2}' | cut -d ',' -f 1) # 401
data=$(curl -s https://data.blazemeter.com/api/v4/data | grep "code" | awk '{print $2}' | cut -d ',' -f 1) # 401
storage=$(curl -s https://storage.blazemeter.com/ping | tr '>' '\n' | grep "pong" | awk '{print $1}') # pong
mock=$(curl -s https://mock.blazemeter.com/api/v1/user | grep "error" | awk '{print $3}' | cut -d '"' -f 2) # 401
keycloak=$(curl -s https://auth.blazemeter.com/api/v1/user | tr '>' '\n' | grep [0-9] | awk '{print $1}') # 404
scriptless=$(curl -s --dump-header - https://bard.blazemeter.com/api/v4/entities/locators | grep "HTTP" | awk '{print $2}') # 401
testdata=$(curl -s https://tdm.blazemeter.com/api/v1/functions | tr ',' '\n' | grep "status" | cut -d ':' -f 3) # 401
bzm_registry=$(curl -s https://gcr.io/verdant-bulwark-278 | grep "H1" | tr '>' ' ' | awk '{print $2}') # 302
docker_registry=$(curl -s --dump-header - https://registry-1.docker.io | grep "HTTP" | awk '{print $2}') # 200

# Verifies connectivity to https://a.blazemeter.com
if [[ $performance == 401 ]]
then
  echo -e "\e[32mConnection to https://a.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://a.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://data.blazemeter.com
if [[ $data == 401 ]]
then
  echo -e "\e[32mConnection to https://data.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://data.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://storage.blazemeter.com
if [[ $storage == "pong" ]]
then
  echo -e "\e[32mConnection to https://storage.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://storage.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://mock.blazemeter.com
if [[ $mock == 401 ]]
then
  echo -e "\e[32mConnection to https://mock.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://mock.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://auth.blazemeter.com
if [[ $keycloak == 404 ]]
then
  echo -e "\e[32mConnection to https://auth.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://auth.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://bard.blazemeter.com
if [[ $scriptless == 401 ]]
then
  echo -e "\e[32mConnection to https://bard.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://bard.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://tdm.blazemeter.com
if [[ $testdata == 401 ]]
then
  echo -e "\e[32mConnection to https://tdm.blazemeter.com successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://tdm.blazemeter.com unsuccessful."
fi

# Verifies connectivity to https://gcr.io/verdant-bulwark-278
if [[ $bzm_registry == 302 ]]
then
  echo -e "\e[32mConnection to https://gcr.io/verdant-bulwark-278 successful."
  connectivity_check=true
else
  echo -e "\e[31mConnection to https://gcr.io/verdant-bulwark-278 unsuccessful."
fi

if [ $is_centos == true ]
then
  if [ $connectivity_check == true ] && [ $version_check == true ] && [ $firewall_check == true ] && [ $selinux_check == true ] && [ $hard_drive_check == true ] && [ $cpu_check == true ] && [ $mem_check == true ] && [ $docker_check == true ]
  then
    echo
    echo -e "\e[32mPASS"
  else
    echo
    echo -e "\e[31mFAIL"
  fi
else
  if [ $connectivity_check == true ] && [ $version_check == true ] && [ $hard_drive_check == true ] && [ $cpu_check == true ] && [ $mem_check == true ] && [ $docker_check == true ]
  then
    echo
    echo -e "\e[32mPASS"
  else
    echo
    echo -e "\e[31mFAIL"
  fi
fi

# Resets font color to defaults
echo -e "\e[39m"