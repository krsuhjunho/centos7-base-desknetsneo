##BASE IMAGE
FROM ghcr.io/krsuhjunho/centos7-base-systemd

##Utils Install
RUN yum install -y epel-release && \
yum install -y make httpd gcc-c++ gnu-make \
readline-devel zlib-devel &&\
yum update -y &&\
systemctl enable httpd; yum clean all

##COPY SOURCE FILE
ADD postgresql-9.6.21.tar.gz /usr/local/src
ADD node-v10.24.0-linux-x64.tar.gz /usr/local/src

COPY RUN-INIT.sh /usr/local/src/RUN-INIT.sh
RUN /usr/local/src/RUN-INIT.sh && \
    rm -rf /usr/local/src/RUN-INIT.sh 

COPY RUN-INSTALL-DESKNETSNEO.sh /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh
RUN /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh && \	
    rm -rf /usr/local/src/* 

##HEALTHCHECK 
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 CMD curl -f http://127.0.0.1/cgi-bin/dneo/dneo.cgi? || exit 1

##WORKDIR
WORKDIR /var/www

##PORT OPEN
EXPOSE 22
EXPOSE 80

CMD ["/usr/sbin/init"]
