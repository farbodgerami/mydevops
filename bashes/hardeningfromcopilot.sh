Hello, this is Bing. I can help you with creating a bash script file for hardening Linux. Here is a sample script that you can use or modify according to your needs:

```bash
#!/bin/bash
# A simple script to harden Linux security

# Set the hostname
hostnamectl set-hostname myserver

# Set the timezone
timedatectl set-timezone Asia/Tehran

# Update the system
apt update && apt upgrade -y

# Create a new admin user
useradd -m -s /bin/bash admin
passwd admin
usermod -aG sudo admin

# Generate SSH keys for the admin user
su - admin -c "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
su - admin -c "cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys"
su - admin -c "chmod 600 ~/.ssh/authorized_keys"

# Configure SSH server
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure iptables rules
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
iptables-save > /etc/iptables/rules.v4



# Install and configure fail2ban
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/port    = ssh/port    = 2222/' /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# Install and configure rkhunter
apt install rkhunter -y
rkhunter --propupd
rkhunter --update
rkhunter --check --sk

# Install and configure unhide
apt install unhide -y
unhide sys
unhide proc

# Install and configure tiger
apt install tiger -y
tiger -e

# Secure root home and grub configuration files
chmod 700 /root
chmod 600 /boot/grub/grub.cfg

# Enable process accounting
apt install acct -y
touch /var/log/wtmp
systemctl enable acct
systemctl start acct

# Enable unattended upgrades
apt install unattended-upgrades -y
dpkg-reconfigure --priority=low unattended-upgrades

# Set a restrictive default umask
echo "umask 027" >> /etc/profile

# Configure auditd rules following CIS benchmark
apt install auditd -y
cp /usr/share/doc/auditd/examples/rules/30-stig.rules /etc/audit/rules.d/
systemctl enable auditd
systemctl start auditd

# Kernel hardening via sysctl configuration file
cat << EOF > /etc/sysctl.d/99-hardening.conf
# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable packet redirect sending
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable packet redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable source routed packet acceptance
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Enable TCP SYN cookie protection
net.ipv4.tcp_syncookies = 1

# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP broadcast echo
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Enable bad error message protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Disable IPv6 router advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Disable IPv6 autoconfiguration
net.ipv6.conf.all.autoconf = 0
net.ipv6.conf.default.autoconf = 0

# Disable IPv6 neighbor solicitations
net.ipv6.conf.all.dad_transmits = 0
net.ipv6.conf.default.dad_transmits = 0

# Disable IPv6 privacy extensions
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0

# Disable IPv6 optimistic DAD
net.ipv6.conf.all.optimistic_dad = 0
net.ipv6.conf.default.optimistic_dad = 0

# Disable IPv6 router preference
net.ipv6.conf.all.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0

# Disable IPv6 hop limit
net.ipv6.conf.all.accept_ra_hlim = 0
net.ipv6.conf.default.accept_ra_hlim = 0

# Disable IPv6 MTU
net.ipv6.conf.all.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_pinfo = 0

# Disable IPv6 route information
net.ipv6.conf.all.accept_ra_defrtr = 0
net.ipv6.conf.default.accept_ra_defrtr = 0

# Disable IPv6 prefix information
net.ipv6.conf.all.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_pinfo = 0

# Disable IPv6 router solicitation
net.ipv6.conf.all.router_solicitations = 0
net.ipv6.conf.default.router_solicitations = 0

# Disable IPv6 redirects
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable IPv6 secure redirects
net.ipv6.conf.all.secure_redirects = 0
net.ipv6.conf.default.secure_redirects = 0

# Disable core dumps
fs.suid_dumpable = 0

# Enable ASLR
kernel.randomize_va_space = 2

# Enable execshield
kernel.exec-shield = 1

# Restrict access to kernel logs
kernel.dmesg_restrict = 1

# Restrict access to kernel pointers
kernel.kptr_restrict = 2

# Disable loading of modules
kernel.modules_disabled = 1
EOF

# Apply the sysctl settings
sysctl --system

# /tmp directory hardening
echo "tmpfs /tmp tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab
mount -a

# Set a GRUB bootloader password
grub-mkpasswd-pbkdf2 | tee grubpassword.tmp
grubpassword=$(cat grubpassword.tmp | sed -e '1,2d' | cut -d ' ' -f7)
echo " set superusers=\"admin\" " >> /etc/grub.d/40_custom
echo " password_pbkdf2 admin $grubpassword " >> /etc/grub.d/40_custom
rm grubpassword.tmp
update-grub

# Disable USB support (optional)
echo "blacklist usb-storage" > /etc/modprobe.d/disable-usb-storage.conf
update-initramfs -u

# Display a warning banner
cat << EOF > /etc/issue.net
*******************************************************************************
*                                                                             *
* Unauthorized access to this system is forbidden and will be prosecuted by   *
* law. By accessing this system, you agree that your actions may be monitored *
* and recorded.                                                               *
*                                                                             *
*******************************************************************************
EOF

cp /etc/issue.net /


