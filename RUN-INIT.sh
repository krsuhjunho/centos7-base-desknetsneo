#!/bin/bash
#VAR
POSTGRESQL="postgresql-9.6.21"
SYSTEMD_PGSQL="/etc/rc.d/init.d/postgresql"
INITD_PGSQL="/etc/init.d/postgresql"
POSTGRES_USER="postgres"
POSTGRES_PSWD="postgres"
USER_APACHE="apache"

#PATH
SRC_PATH="/usr/local/src/"
PGSQL_PATH="/var/pgsql"
PGSQL_DATA_PATH="/var/pgsql/data"
NODEJS_PATH="${SRC_PATH}node-v10.24.0-linux-x64"
POSTGRESQL_PATH="${SRC_PATH}${POSTGRESQL}"
CGI_PATH="/var/www/cgi-bin"
HTML_PATH="/var/www/html"
DNEO_PATH="/var/www/cgi-bin/dneo"
DNEOSP_PATH="/var/www/cgi-bin/dneosp"


ECHO_MESSAGE()
{
echo ""
echo "##########${1}###########"
echo ""
}

####################	POSTGRESQL INSTALL	###################
POSTGRESQL_INSTALL()
{
ECHO_MESSAGE "Postgres Install Start"
ECHO_MESSAGE "POSTGRESQL VER => ${POSTGRESQL}"
ECHO_MESSAGE "POSTGRESQL PATH => ${POSTGRESQL_PATH}"

#configure
ECHO_MESSAGE "Postgres Configure"
cd ${POSTGRESQL_PATH}
./configure

#gmake
ECHO_MESSAGE "Postgres Compile Start"
gmake

#useradd guest && gmake check
ECHO_MESSAGE "Postgres Guest User Check"
useradd guest
su guest -c 'gmake check'

#install
ECHO_MESSAGE "Postgres Install"
gmake install
cd contrib/dblink
gmake
gmake install
cd ../..

#Compile Clean
ECHO_MESSAGE "Postgres Install Clean"
gmake clean
}

####################	NODE JS INSTALL	###################
NODEJS_INSTALL()
{
#NODE JS INSTALL 
ECHO_MESSAGE "NODE JS INSTALL"
cd ${NODEJS_PATH}
cp -a bin include lib share /usr/local
node -v
}

####################	POSTGRES USER ADD && PW SETUP	###################
POSTGRESQL_USER_SETUP()
{
ECHO_MESSAGE "POSTGRES USER CREATE && PW SETUP"
useradd ${POSTGRES_USER}
passwd ${POSTGRES_USER}<<EOF
postgres
postgres
EOF
}

####################	POSTGRESQL RESTORE	###################
POSTGRESQL_INIT()
{

#POSTGRESQL INIT START
ECHO_MESSAGE "POSTGRESQL INIT START"
mkdir -p ${PGSQL_DATA_PATH}
chown -R ${POSTGRES_USER}:${POSTGRES_USER} ${PGSQL_PATH}

#SET POSTGRES USER .BASH_PROFILE
ECHO_MESSAGE "SET POSTGRES USER .BASH_PROFILE"
su - ${POSTGRES_USER} -c "sed -i 's/PATH=\$PATH:\$HOME\/.local\/bin:\$HOME\/bin/PATH=\$PATH:\$HOME\/.local\/bin:\$HOME\/bin:\/usr\/local\/pgsql\/bin/g' ~/.bash_profile"
su - ${POSTGRES_USER} -c "source ~/.bash_profile"
sleep 1

#POSTGRESQL DB INIT START
ECHO_MESSAGE "POSTGRESQL DB INIT START"
su - ${POSTGRES_USER} -c 'initdb --encoding=utf8 --locale=C -D /var/pgsql/data'
sleep 1

#POSTGRESQL START
ECHO_MESSAGE "POSTGRESQL START"
su - ${POSTGRES_USER} -c 'pg_ctl -D /var/pgsql/data -l logfile start'
sleep 1

#POSTGRESQL DB PASSWORD CHANGE && Test Database Create
ECHO_MESSAGE "DB INIT PASSWORD"
su - ${POSTGRES_USER} -c 'createdb test'
su - ${POSTGRES_USER} -c "psql test"<<EOF
\l
alter role postgres with password 'postgres';
\q
EOF
sleep 2

#POSTGRES Trust To MD5 SETUP
ECHO_MESSAGE "POSTGRES Trust To MD5 SETUP"
su - ${POSTGRES_USER} -c "cat ${PGSQL_DATA_PATH}/pg_hba.conf | grep trust"
su - ${POSTGRES_USER} -c "sed -i '83,89s/trust/md5/g' /var/pgsql/data/pg_hba.conf"
su - ${POSTGRES_USER} -c "cat ${PGSQL_DATA_PATH}/pg_hba.conf | grep md5 "
su - ${POSTGRES_USER} -c 'pg_ctl -D /var/pgsql/data reload'
sleep 2

#DB INIT DATAPATH
ECHO_MESSAGE "DB INIT DATAPATH"
cd ${POSTGRESQL_PATH}/contrib/start-scripts/
cp linux ${INITD_PGSQL}
chmod 777 ${INITD_PGSQL}
sed -i '30,40s#/usr/local/pgsql/data#/var/pgsql/data#g' ${INITD_PGSQL}
cat ${INITD_PGSQL} | grep "PGDATA="
sleep 2


#DB AutoRestart SETUP
ECHO_MESSAGE "DB AutoRestart SETUP"
chkconfig --add postgresql
chkconfig --list | grep postgresql
}

##############	DB INIT CREATEROLE	################
POSTGRESQL_DESKNETSNEO_INIT()
{
ECHO_MESSAGE "Desknets Neo DB INIT CREATEROLE"
su - ${POSTGRES_USER} -c "psql template1"<<EOF
postgres
CREATE USER dneo WITH PASSWORD 'desknetsNeo_PgSql' CREATEROLE;
CREATE USER dneofts WITH PASSWORD 'dneofts' CREATEROLE;
CREATE USER dneoconv WITH PASSWORD 'dneoconv' CREATEROLE;
EOF
}

#############	HTTPD SETENV LIBRARY_PATH	################
HTTPD_DESKNETSNEO_INIT()
{
ECHO_MESSAGE "HTTPD SETENV LIBRARY_PATH"
echo "SetEnv LD_LIBRARY_PATH ${DNEO_PATH}/lib" >> /etc/httpd/conf/httpd.conf
}


####################	MAIN SHELL START	###################
MAIN()
{
POSTGRESQL_INSTALL
NODEJS_INSTALL
POSTGRESQL_USER_SETUP
POSTGRESQL_INIT
POSTGRESQL_DESKNETSNEO_INIT
HTTPD_DESKNETSNEO_INIT
}

MAIN