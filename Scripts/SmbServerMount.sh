#/bin/bash



read -p "Enter Server IP : " SERVER_IP


read -p "Enter Share Name : " SHARE_NAME


read -p "Enter User Name : " USERNAME


read -sp "Enter password: " PASSWD

#DOMAIN="domain"


#mount.cifs //$SERVER_IP/$SHARE_NAME /mnt/NasServer/ -o username=$USERNAME,password=$PASSWD,dom=$DOMAIN
mount.cifs //$SERVER_IP/$SHARE_NAME /mnt/NasServer/ -o vers=3.0 -o username=$USERNAME,password=$PASSWD