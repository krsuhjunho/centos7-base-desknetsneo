#!/bin/bash

#VAR

POSTGRES_USER="postgres"
USER_APACHE="apache"

#PATH
SRC_PATH="/usr/local/src/"
CGI_PATH="/var/www/cgi-bin"
HTML_PATH="/var/www/html"
DNEO_PATH="/var/www/cgi-bin/dneo"
DNEOSP_PATH="/var/www/cgi-bin/dneosp"
DNEOFILE_NAME="dneoV40R13pg96lRE6.tar.gz"
DNEOFILE_URL="https://www.desknets.com/binary/neo/linuxpg96/${DNEOFILE_NAME}"
DNEO_VER="4.0.1.3"

ECHO_MESSAGE()
{
echo ""
echo "##########${1}###########"
echo ""
}

POSTGRESQL_START()
{
ECHO_MESSAGE "POSTGRESQL START"
su - ${POSTGRES_USER} -c 'pg_ctl -D /var/pgsql/data -l logfile start'
}


####################	DESKNETS NEO INSTALL	###################
DESKNETSNEO_INSTALL()
{
ECHO_MESSAGE "DESKNETS NEO ${DNEO_VER} INSTALL"
cd ${CGI_PATH}
wget ${DNEOFILE_URL}
tar -zxf ${DNEOFILE_NAME}
chown -R ${USER_APACHE}:${USER_APACHE} ${DNEO_PATH}
chown -R ${USER_APACHE}:${USER_APACHE} ${DNEOSP_PATH}
mv ${DNEO_PATH}/dneores ${HTML_PATH}/.
mv ${DNEO_PATH}/dneowmlroot ${HTML_PATH}/.
mv ${DNEOSP_PATH}/dneospres ${HTML_PATH}/.
rm -rf ${DNEOFILE_NAME}


ECHO_MESSAGE "INIT START dneodb.pgdmp"
su - ${POSTGRES_USER} -c 'pg_restore -C -Fc -d template1 /var/www/cgi-bin/dneo/dump/dneodb.pgdmp'<<EOF
postgres
EOF

ECHO_MESSAGE "INIT START dneologdb.pgdmp"
su - ${POSTGRES_USER} -c 'pg_restore -C -Fc -d template1 /var/www/cgi-bin/dneo/dump/dneologdb.pgdmp'<<EOF
postgres
EOF

ECHO_MESSAGE "INIT START dneoftsdb.pgdmp"
su - ${POSTGRES_USER} -c 'pg_restore -C -Fc -d template1 /var/www/cgi-bin/dneo/dump/dneoftsdb.pgdmp'<<EOF
postgres
EOF

}

MAIN()
{
POSTGRESQL_START
DESKNETSNEO_INSTALL
}

MAIN
