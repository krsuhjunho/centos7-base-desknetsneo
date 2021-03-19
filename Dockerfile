##BASE IMAGE
FROM wnwnsgh/centos7-base-systemd

##Utils Install
RUN set -x  yum update -y && yum upgrade -y  && \
yum install -y epel-release && \
yum install -y wget htop httpd openssl vim unzip zip \
openssh-server openssh-clients git \
ncdu tree cronie gcc-c++ gnu-make \
readline-devel zlib-devel &&\
systemctl enable httpd; yum clean all

#COPY SOURCE FILE
ADD postgresql-9.6.21.tar.gz /usr/local/src
ADD node-v10.24.0-linux-x64.tar.gz /usr/local/src

COPY RUN-INIT.sh /usr/local/src/RUN-INIT.sh
RUN /usr/local/src/RUN-INIT.sh && \
    rm -rf /usr/local/src/RUN-INIT.sh 

COPY RUN-INSTALL-DESKNETSNEO.sh /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh
RUN /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh && \	
    rm -rf /usr/local/src/* 

##PORT OPEN
EXPOSE 22
EXPOSE 80

CMD ["/usr/sbin/init"]
