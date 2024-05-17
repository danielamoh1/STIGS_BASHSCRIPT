#!/bin/bash

# STIG Bash Script for RHEL 9
# This script applies basic STIG hardening settings

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# 1. Set permissions for cron directories
chmod 0700 /etc/cron.d
chmod 0700 /etc/cron.daily
chmod 0700 /etc/cron.hourly
chmod 0700 /etc/cron.monthly
chmod 0700 /etc/cron.weekly

# 2. Set permissions for log directories
chmod 0755 /var/log

# 3. Configure sysctl settings for network security
cat << EOF >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 1
net.ipv4.conf.default.secure_redirects = 1
EOF
sysctl -p

# 4. Enable auditing for key system events
auditctl -a always,exit -F arch=b64 -S execve -k exec-logs
auditctl -w /etc/sudoers -p wa -k actions
auditctl -w /etc/passwd -p wa -k passwd_changes
auditctl -w /etc/shadow -p wa -k shadow_changes

# 5. Configure logging settings
cat << EOF >> /etc/rsyslog.conf
*.info;mail.none;authpriv.none;cron.none /var/log/messages
authpriv.* /var/log/secure
mail.* -/var/log/maillog
cron.* /var/log/cron
*.emerg :omusrmsg:*
EOF
systemctl restart rsyslog

# 6. Disable core dumps
echo '* hard core 0' >> /etc/security/limits.conf
sysctl -w fs.suid_dumpable=0
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf

# 7. Restrict the use of cron
chmod 0700 /etc/cron.allow
chmod 0700 /etc/cron.deny
touch /etc/cron.allow
echo "root" > /etc/cron.allow

# 8. Disable unused filesystems
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf

# 9. Ensure no exec permissions on user home directories
find /home -type d -exec chmod go-rwx {} \;
find /home -type f -exec chmod go-rwx {} \;

# 10. Ensure audit logs are immutable
echo "-e 2" > /etc/audit/rules.d/99-final.rules

# Notify user of completion
echo "STIG hardening script completed."
