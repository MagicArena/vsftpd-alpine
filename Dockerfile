FROM alpine:latest

LABEL cn.magicarnea.description="Vsftpd Docker image based on alpine forked from fauria/vsftpd
. Supports passive mode, SSL and virtual users." \
      cn.magicarnea.vendor="MagicArena" \
      cn.magicarnea.maintainer="everoctivian@gmail.com" \
      cn.magicarnea.versionCode=1 \
      cn.magicarnea.versionName="3.0.3"

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21 21100-21110

# if you want use APK mirror then uncomment, modify the mirror address to which you favor
# RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://mirrors.aliyun.com|g' /etc/apk/repositories

ENV TZ=Asia/Shanghai
RUN set -ex && \
    apk add --no-cache ca-certificates curl tzdata shadow build-base linux-pam-dev unzip vsftpd openssl && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /tmp/* /var/cache/apk/*

# make pam_pwdfile.so
COPY libpam-pwdfile.zip /tmp/
RUN set -ex && \
    unzip -q /tmp/libpam-pwdfile.zip -d /tmp/ && \
    cd /tmp/libpam-pwdfile && \
    make install && \
    rm -rf /tmp/libpam-pwdfile && \
    rm -f /tmp/libpam-pwdfile.zip

ENV FTP_USER **String**
ENV FTP_PASS **Random**
ENV PASV_ADDRESS **IPv4**
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110

COPY install.sh /usr/sbin/
COPY ./etc/vsftpd/vsftpd.conf /etc/vsftpd/
COPY ./etc/vsftpd/vsftpd_virtual /etc/pam.d/

RUN set -ex && \
    chmod +x /usr/sbin/install.sh && \
    mkdir -p /var/log/vsftpd/ && \
    mkdir -p /etc/vsftpd/vuser_conf/ && \
    mkdir -p /var/mail/ && \
    useradd ftpuser -m -d /home/ftpuser/ -s /sbin/nologin && \
    chown -R ftpuser:ftpuser /home/vsftpd/

CMD ["/usr/sbin/install.sh"]