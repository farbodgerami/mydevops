#!/bin/bash
# ssh farbod@192.168.122.210 && cp /home/debian/.ssh/authorized_keys /root/.ssh/authorized_keys
IPS=(37.32.31.152)
USER=ubuntu
sshport=22
server_length=${#IPS[@]}
i=0

mkdir /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
ssh $USER@${IPS[$i]} 'cat <<EOT >> /home/$USER/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICnHlZcyxRPe97vWcuKbrbQloAOWu2BwEXPXQ/y/bWEw “ansible”
EOT'  
echo  1 | sudo -S cp /home/$USER/.ssh/authorized_keys /root/.ssh/
echo  1 | sudo -S cp /home/$USER/.bashrc /root/
echo  1 | sudo -S sed -i 's/#Port 22/Port 8431/g' /etc/ssh/sshd_config
echo  1 | sudo -S systemctl restart sshd


#  ssh -p 22 fb@192.168.122.106 'echo  1 | sudo -S sed -i 's/#Port 22/Port 8431/g' /etc/ssh/sshd_config'