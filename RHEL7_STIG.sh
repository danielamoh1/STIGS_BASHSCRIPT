#!/bin/bash
#
# Script to apply DISA STIGs to CentOS/RHEL
#

# 1. Set the hostname
echo "Setting the hostname"
hostnamectl set-hostname myhostname

# 2. Disable unused services
echo "Disabling unused services"
systemctl disable avahi-daemon.service
systemctl disable bluetooth.service
systemctl disable cups.service
systemctl disable dhcpd.service
systemctl disable slapd.service
systemctl disable nfs.service

# 3. Enable firewalld and configure rules
echo "Enabling firewalld"
systemctl enable firewalld
echo "Configuring firewalld rules"
firewall-cmd --add-service=ssh --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --reload

# 4. Update the system
echo "Updating the system"
yum update -y

# 5. Set password policies
echo "Setting password policies"
authconfig --passalgo=sha512 --remember=5 --update

# 6. Configure SSH
echo "Configuring SSH"
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
systemctl restart sshd

# 7. Set umask value
echo "Setting umask value"
echo "umask 027" >> /etc/bashrc

# 8. Limit cron access
echo "Limiting cron access"
echo "root" > /etc/cron.allow
echo "admin" > /etc/cron.allow
echo "root" > /etc/at.allow
echo "admin" > /etc/at.allow

# 9. Configure auditd
echo "Configuring auditd"
sed -i 's/.*max_log_file_action.*/max_log_file_action = keep_logs/g' /etc/audit/auditd.conf
systemctl enable auditd.service
systemctl start auditd.service

# 10. Set SELinux to enforcing
echo "Setting SELinux to enforcing"
setenforce 1
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
