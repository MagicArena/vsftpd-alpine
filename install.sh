#!/bin/sh

# If no env var for FTP_USER has been specified, use 'admin':
if [ "$FTP_USER" = "**String**" ]; then
  export FTP_USER='admin'
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS" = "**Random**" ]; then
  export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
fi

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
  # export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
  export PASV_ADDRESS=$(curl -s -4 --connect-timeout 5 --max-time 10 ifconfig.co)
fi

export GLOBAL_CONFIG_FILE="/etc/vsftpd/vsftpd.conf"

if [ -z "$(grep "pasv_max_port=" /etc/vsftpd/vsftpd.conf)" ]; then
  echo "pasv_max_port=${PASV_MAX_PORT}" >> ${GLOBAL_CONFIG_FILE}
  echo "pasv_min_port=${PASV_MIN_PORT}" >> ${GLOBAL_CONFIG_FILE}
  echo "pasv_address=${PASV_ADDRESS}" >> ${GLOBAL_CONFIG_FILE}
fi

# # Execute add ftp user script
# if [ -n "${ADD_FTP_USER_SCRIPT}" ] && [ ! -s "/etc/vsftpd/vuser_passwd" ]; then
#   if [ -s "/etc/vsftpd/vsftpd-add-ftp-user.sh" ]; then
#     chmod +x /etc/vsftpd/vsftpd-add-ftp-user.sh
#     /etc/vsftpd/vsftpd-add-ftp-user.sh
#   fi
# fi

# fix ftp home permissions
chown -R ftpuser:ftpuser /home/vsftpd/

# Run vsftpd:
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
