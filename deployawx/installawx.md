***Awx installation:***
**first of all, needed ports must be opened and docker installation is mandatory**
*get related docker images:*
```
docker pull postgres:12
docker pull ansible/awx:17.1.0
docker pull redis
```
**1-clone awx project version 17.10:**
```
git clone -b 17.1.0 https://github.com/ansible/awx.git
  or 
wget https://codeload.github.com/ansible/awx/zip/refs/tags/17.1.0
```
**2-install certbot:**
```
apt install -y certbot
apt install ansible
apt install unzip
apt install docker-compose
```
**3- Create certificate with certbot command**
```
DOMAIN=<YOUR DOMAIN>
EMAIL=<YOUR EMAIL>
certbot  certonly  \
--standalone \
--non-interactive  \
--agree-tos \
--no-eff-email  \
--no-redirect \
--email ${EMAIL} \
--domains ${DOMAIN}
```
**4-now in the cloned awx project put run this command:**
```
cat <<EOS > installer/inventory
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"
[all:vars]
DOMAIN=<YOUR_DOMAIN>
dockerhub_base=ansible
dockerhub_version=17.1.0
admin_password=<YOUR ADMIN PASSWROD>
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir="<YOUR_AWX_PROJECT_DIRECTORY>/pgdocker"
host_port=80
host_port_ssl=443
docker_compose_dir="<YOUR_AWX_PROJECT_DIRECTORY>/awxcompose"
pg_username=awx
pg_password=12348769tgyugfvyhjrdhtrdhytfu5t6
pg_database=awx
pg_port=5432
admin_user=admin
create_preload_data=True
secret_key=12348769tgyugfvyhjrdhtrdhytfu5t6
awx_alternate_dns_servers="178.22.122.100,185.51.200.2"
project_data_dir=<YOUR_AWX_PROJECT_DIRECTORY>/projects
ssl_certificate=/etc/letsencrypt/archive/<YOUR_DOMAIN>/fullchain1.pem
ssl_certificate_key=/etc/letsencrypt/archive/<YOUR_DOMAIN>/privkey1.pem
```
5-**now install awx**
```bash
ansible-playbook  -i  installer/inventory  installer/install.yml  -v
```

for a better undrestanding, you can refer to installawx.sh file in this directory