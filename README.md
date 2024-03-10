# STIGS_BASHSCRIPT

![photo_2024-03-10_18-36-52](https://github.com/danielamoh1/STIGS_BASHSCRIPT/assets/160555417/a51da9aa-68c7-4be2-98fe-ccbcf31274b9)

I made a bash script is designed to automate the process of applying DISA STIG (Defense Information Systems Agency Security Technical Implementation Guide) compliance measures to a CentOS/RHEL system. So to get into it:


First, I would set the hostname of the system by using the hostnamectl set-hostname command, providing the desired hostname.

Next, I would disable unused services to ensure better security. This involves running the systemctl disable command for each service that is deemed unnecessary, such as avahi-daemon, bluetooth, cups, dhcpd, slapd, and nfs.

To enhance the system's security, I would enable firewalld by executing the systemctl enable firewalld command. Afterward, I would configure the firewalld rules by using the firewall-cmd command to add the necessary services like SSH, HTTP, and HTTPS.

To keep the system up-to-date with the latest security patches and updates, I would run the yum update -y command, which automatically answers "yes" to any prompts.

To comply with password security requirements, I would set the password policies by running the authconfig --passalgo=sha512 --remember=5 --update command.

For SSH configuration, I would modify the /etc/ssh/sshd_config file using the sed command. Specifically, I would replace #PermitRootLogin yes with PermitRootLogin no to disable root login, and change #LogLevel INFO to LogLevel VERBOSE to increase the verbosity level of SSH logging. Finally, I would restart the SSH service using systemctl restart sshd.

To set the umask value, I would append umask 027 to the /etc/bashrc file.

To limit cron access, I would create /etc/cron.allow and /etc/at.allow files and add the appropriate users (root and admin) to restrict access.

For configuring auditd, I would modify the /etc/audit/auditd.conf file using the sed command to set max_log_file_action to keep_logs. Then, I would enable and start the auditd service using the systemctl commands.

Lastly, I would set SELinux to enforcing mode by running the setenforce 1 command and modifying the /etc/selinux/config file to change SELINUX=permissive to SELINUX=enforcing using the sed command.

In summary, this script automates the process of applying DISA STIG compliance measures to a CentOS/RHEL system by performing a series of steps that enhance security, configure system settings, and enforce policies to meet the STIG requirements.
