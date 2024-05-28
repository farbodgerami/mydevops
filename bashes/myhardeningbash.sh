 
#!/bin/bash
# cat <<EOT >> /etc/apt/sources.list
# deb http://deb.debian.org/debian bookworm main
# deb http://deb.debian.org/debian bookworm-updates main
# deb http://deb.debian.org/debian-security bookworm-security main
# EOT
hostnamectl set-hostname mymachine
timedatectl set-timezone Asia/Tehran
SSH_PORT=8431

sudo apt-get update &&  sudo apt dist-upgrade && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove
sudo apt update  && sudo apt autoclean && sudo apt clean && sudo apt autoremove

sudo apt install -y lynis libpam-tmpdir fail2ban debsums chkrootkit apt-show-versions ufw resolvconf \
                    needrestart dnsutils sysstat auditd atop software-properties-common \
                    tcpdump axel iftop jq ncdu unzip net-tools cracklib-runtime libpwquality-common apt-listchanges \
                    wget git vim nano bash-completion curl htop sudo ntp apache2-utils telnet iptables-persistent 

# +5



#-------------------------------------------------------------
# postfix Service: disable, stop and mask
echo -e " \e[30;48;5;56m \e[1m \e[38;5;15mpostfix Service: disable, stop and mask \e[0m"
systemctl stop postfix
systemctl disable postfix
systemctl mask postfix

#-------------------------------------------------------------
# firewalld Service: disable, stop and mask
echo -e " \e[30;48;5;56m \e[1m \e[38;5;15mfirewalld Service: disable, stop and mask \e[0m"
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

#-------------------------------------------------------------
# ufw Service: disable, stop and mask
echo -e " \e[30;48;5;56m \e[1m \e[38;5;15mufw Service: disable, stop and mask \e[0m"
systemctl stop ufw
systemctl disable ufw
systemctl mask ufw


# Disable unused filesystems and network protocols
echo "install cramfs /bin/true" > /etc/modprobe.d/cramfs.conf
echo "install freevxfs /bin/true" > /etc/modprobe.d/freevxfs.conf
echo "install jffs2 /bin/true" > /etc/modprobe.d/jffs2.conf
echo "install hfs /bin/true" > /etc/modprobe.d/hfs.conf
echo "install hfsplus /bin/true" > /etc/modprobe.d/hfsplus.conf
echo "install squashfs /bin/true" > /etc/modprobe.d/squashfs.conf
echo "install udf /bin/true" > /etc/modprobe.d/udf.conf
echo "install dccp /bin/true" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/true" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/true" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/true" > /etc/modprobe.d/tipc.conf
# +2

apt remove -y snapd && apt purge -y snapd
# +1




apt install tiger -y
tiger -e
# +1

apt install acct -y
touch /var/log/wtmp
systemctl enable acct
systemctl start acct
#+1


grub-mkpasswd-pbkdf2 | tee grubpassword.tmp
grubpassword=galaxy
echo " set superusers=\"admin\" " >> /etc/grub.d/40_custom
echo " password_pbkdf2 admin $grubpassword " >> /etc/grub.d/40_custom
rm grubpassword.tmp
update-grub
#+1

cat <<EOT >> /etc/security/limits.conf
* hard core 0
* soft core 0
EOT

rm /etc/ssh/sshd_config
touch /etc/ssh/sshd_config

cat <<EOT > /etc/ssh/sshd_config
Include /etc/ssh/sshd_config.d/*.conf

Port $SSH_PORT
X11Forwarding no
 
IgnoreRhosts yes
PermitEmptyPasswords no
MaxAuthTries 3
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin without-password

AllowTcpForwarding no
ClientAliveCountMax 2
Compression no
LogLevel VERBOSE
MaxSessions 2
TCPKeepAlive no
AllowAgentForwarding no


KbdInteractiveAuthentication no
UsePAM yes
PrintMotd no
AcceptEnv LANG LC_*


Subsystem	sftp	/usr/lib/openssh/sftp-server


ListenAddress 0.0.0.0

ChallengeResponseAuthentication no
GSSAPIAuthentication no
ClientAliveInterval 10
UseDNS no
EOT
systemctl restart sshd.service
#+9

cat <<EOT > /etc/sysctl.conf
# Decrease TIME_WAIT seconds
net.ipv4.tcp_fin_timeout = 30
 
# Recycle and Reuse TIME_WAIT sockets faster
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1

# Decrease ESTABLISHED seconds
net.netfilter.nf_conntrack_tcp_timeout_established=3600

# Maximum Number Of Open Files
fs.file-max = 500000
# 
vm.max_map_count=262144

net.ipv4.ip_nonlocal_bind = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1

#Kernel Hardening
fs.suid_dumpable = 0
kernel.core_uses_pid = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0 
net.ipv4.conf.all.log_martians = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

#New Kernel Hardening
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
 

# Disable Ipv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.conf.all.rp_filter=1
kernel.yama.ptrace_scope=1

dev.tty.ldisc_autoload = 0
fs.protected_fifos = 2

kernel.unprivileged_bpf_disabled = 1

net.core.bpf_jit_harden = 2

net.ipv4.conf.all.forwarding = 0

net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
kernel.perf_event_paranoid = 3



EOT
modprobe br_netfilter

sysctl -p
# sysctl config apply 
#+4
# moshkel darad:
# kernel.modules_disabled = 1
ufw enable 
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT
# ufw allow ssh
# ufw allow https
# ufw allow http

# create ssh banner -------------------------------------------
cat <<EOT > /etc/issue.net 
------------------------------------------------------------------------------
* WARNING.....                                                               *
* You are accessing a secured system and your actions will be logged along   *
* with identifying information. Disconnect immediately if you are not an     *
* authorized user of this system.                                            *
------------------------------------------------------------------------------
EOT

cat <<EOT >>  /etc/issue
------------------------------------------------------------------------------
* WARNING.....                                                               *
* You are accessing a secured system and your actions will be logged along   *
* with identifying information. Disconnect immediately if you are not an     *
* authorized user of this system.                                            *
------------------------------------------------------------------------------
EOT

# test:
chmod 600 /etc/sudoers.d

touch /var/log/auth.log 
cat << EOT > /etc/jail.local
[DEFAULT]
bantime=1h
banaction=ufw
[sshd]
enabled = true
logpath = /var/log/auth.log
port    = $SSH_PORT

[dropbear]
port    = $SSH_PORT

[selinux-ssh]
port    = $SSH_PORT
EOT

# service restart and status service
systemctl enable fail2ban.service 
systemctl restart fail2ban.service
 
fail2ban-client status




echo -e " \e[30;48;5;56m \e[1m \e[38;5;15mTimeout Setting \e[0m"
echo -e '#!/bin/bash\n### 300 seconds == 5 minutes ##\nTMOUT=300\nreadonly TMOUT\nexport TMOUT' > /etc/profile.d/timout-settings.sh
cat /etc/profile.d/timout-settings.sh




# Disable IP forwarding
 


 