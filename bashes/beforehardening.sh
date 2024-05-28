#!/bin/bash
# ssh farbod@192.168.122.210 && cp /home/debian/.ssh/authorized_keys /root/.ssh/authorized_keys
IPS=(5.34.206.67)
USER=ubuntu
sshport=22
server_length=${#IPS[@]}
i=0
while [ $i -lt $server_length ]
do
   # ssh ${IPS[$i]} << EOS
    ssh -p ${sshport} $USER@${IPS[$i]} << EOS
    cat /home/$USER/.ssh/authorized_keys | sudo tee /root/.ssh/authorized_keys
    sudo cp /home/$USER/.bashrc /root/
    sudo sed -i 's/#Port 22/Port 8431/g' /etc/ssh/sshd_config
    sudo cat /etc/ssh/sshd_config | grep Port
    sudo systemctl restart sshd
    #sudo sed -i 's/#DNS=/DNS=178.22.122.100 185.51.200.2/g' /etc/systemd/resolved.conf
    #sudo systemctl restart systemd-resolved.service
EOS
    ((i++))
done
