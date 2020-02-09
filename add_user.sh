#!/bin/sh

USER_NAME=$1
USER_PASSWORD=$2
USER_CONFIG_FILE=$3

mkdir -p /home/ftpuser/myuser

echo "${USER_NAME}:$(openssl passwd -1 ${USER_PASSWORD})" >> /etc/vsftpd/vuser_passwd
cat > ${USER_CONFIG_FILE} <<EOF
anon_world_readable_only=NO
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
local_root=/home/vsftpd/${USER_NAME}
EOF
