#!/bin/bash
#install docker 
*Awx installation:*
#-install some of needed packages:

apt install -y certbot
apt install -y ansible
apt install -y unzip
apt install -y docker-compose
docker pull postgres:12
docker pull ansible/awx:17.1.0
docker pull redis
wait

#-clone awx project version 17.10
inventoryAddress=awx-17.1.0/installer
#git clone -b 17.1.0 https://github.com/ansible/awx.git
wait
wget https://codeload.github.com/ansible/awx/zip/refs/tags/17.1.0
unzip 17.1.0
wait

wait
#- Create certificate with certbot command

DOMAIN=awx.tlow.ir
EMAIL=fb.gerami@gmail.com
certbot  certonly  \
--standalone \
--non-interactive  \
--agree-tos \
--no-eff-email  \
--no-redirect \
--email ${EMAIL} \
--domains ${DOMAIN}

#-now in the cloned awx project put run this command:
wait
cat <<EOS > $inventoryAddress/inventory
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"
[all:vars]
DOMAIN=awx.tlow.ir
dockerhub_base=ansible
dockerhub_version=17.1.0
admin_password=1234
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="/home/ubuntu/awx/awx-17.1.0/pgdocker"
host_port=80
host_port_ssl=443
docker_compose_dir="/home/ubuntu/awx/awx-17.1.0/awxcompose"
pg_username=awx
pg_password=12348769tgyugfvyhjrdhtrdhytfu5t6
pg_database=awx
pg_port=5432
admin_user=admin
create_preload_data=True
secret_key=12348769tgyugfvyhjrdhtrdhytfu5t6
awx_alternate_dns_servers="178.22.122.100,185.51.200.2"
project_data_dir=/home/ubuntu/awx/awx-17.1.0/projects
ssl_certificate=/etc/letsencrypt/archive/awx.tlow.ir/fullchain1.pem
ssl_certificate_key=/etc/letsencrypt/archive/awx.tlow.ir/privkey1.pem
EOS
wait
#-now install awx
ansible-playbook  -i  $inventoryAddress/inventory  $inventoryAddress/install.yml  -v
