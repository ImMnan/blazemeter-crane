This is an automated script to setup docker to support blazemeter-crane container. The script will also support setting up docker to support ARM based architechture to support AMD64 based containers. 

Requirements:
1. A Blazemeter account
2. Permissions to create Private location and Agent in Blazemeter
3. Root priviledges or part of the sudoers group in the local machine - where the plan is to setup private location agent.
4. Create private location in Blazemeter : https://guide.blazemeter.com/hc/en-us/articles/207421655-Creating-a-Private-Location-Creating-a-Private-Location
5. Create an agent under the private-location in Blazemeter : https://guide.blazemeter.com/hc/en-us/articles/360017746838
6. Copy the docker command and paste into the notepad to use it when the script promted for details. 
7. Make the bash scripts executable give permissions based on your policies, the command is based on 770 - user + group can execute- chmod 770 docker_bm-crane.sh logs.sh requirements_check.sh
8. Before, initiating the script, make sure your system meets the requirements standards for Blazemeter crane container : https://guide.blazemeter.com/hc/en-us/articles/209186065-Private-Location-System-Requirements-Private-Location-System-Requirements
9. If in doubt, you can RUN requirements_check.sh to check if the system is meeting the specified requirement to handle Blazemeter-crane operations.
10. Run logs.sh while raising a support ticket with Blazemeter, share crane.log
11. In case the blaze-crane container does not run, or keeps restarting, you can run restart.sh (Only works if all the images are downloaded and Blazemeter-crane container is available)

https://github.com/ImMnan/blazemeter-crane.git