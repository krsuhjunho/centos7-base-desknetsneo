#########################################################################
#       Centos7-Base-DeskNetsNeo  Container Image                       #
#       https://github.com/krsuhjunho/centos7-base-desknetsneo          #
#       BASE IMAGE: ghcr.io/krsuhjunho/centos7-base-systemd             #
#########################################################################

FROM ghcr.io/krsuhjunho/centos7-base-systemd

#########################################################################
#       Install && Update                                               #
#########################################################################

RUN yum install -y -q make \
		httpd \
		gcc-c++ \
		gnu-make \
		readline-devel \
		zlib-devel &&\
		yum update -y -q &&\
		systemctl enable httpd; \
		yum clean all

#########################################################################
#       POSTGRESQL 9.6.21 Source File Copy                              #
#########################################################################
ADD postgresql-9.6.21.tar.gz /usr/local/src

#########################################################################
#       NODE 10.24.0 Source File Copy                              		#
#########################################################################
ADD node-v10.24.0-linux-x64.tar.gz /usr/local/src


#########################################################################
#       Postgresql 9.6.21 Init-Shell Copy && Run                        #
#########################################################################
COPY RUN-INIT.sh /usr/local/src/RUN-INIT.sh
RUN /usr/local/src/RUN-INIT.sh && \
    rm -rf /usr/local/src/RUN-INIT.sh 

#########################################################################
#       DeskNetsNeo Install-Shell Copy && Run                           #
#########################################################################
COPY RUN-INSTALL-DESKNETSNEO.sh /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh
RUN /usr/local/src/RUN-INSTALL-DESKNETSNEO.sh && \	
    rm -rf /usr/local/src/* 

#########################################################################
#       HEALTHCHECK                                                     #
#########################################################################
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 CMD curl -f http://127.0.0.1/cgi-bin/dneo/dneo.cgi? || exit 1

#########################################################################
#       WORKDIR SETUP                                                   #
#########################################################################
WORKDIR /var/www

#########################################################################
#       PORT OPEN                                                       #
#       SSH PORT 22                                                     #
#       HTTP PORT 80                                                    #
#########################################################################
EXPOSE 22
EXPOSE 80

#########################################################################
#       Systemd                                                         #
#########################################################################
CMD ["/usr/sbin/init"]
