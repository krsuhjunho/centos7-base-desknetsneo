#!/bin/bash

DOCKER_CONTAINER_NAME="neo-test"
CONTAINER_HOST_NAME="neo-test"
SSH_PORT=22457
HTTP_PORT=8012
BASE_IMAGE_NAME="wnwnsgh/centos7-base-desknetsneo"
SERVER_IP=$(curl -s ifconfig.me)
PC_URL="cgi-bin/dneo/dneo.cgi?"
MOBILE_URL="cgi-bin/dneosp/dneosp.cgi"
HTTP_BASE="http://"

docker build -t ${BASE_IMAGE_NAME} .

docker rm -f ${DOCKER_CONTAINER_NAME}

docker run -tid --privileged=true \
-h "${CONTAINER_HOST_NAME}" \
--name="${DOCKER_CONTAINER_NAME}" \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /etc/localtime:/etc/localtime:ro \
-e TZ=Asia/Tokyo \
-p ${SSH_PORT}:22 -p ${HTTP_PORT}:80 \
${BASE_IMAGE_NAME}


#docker exec -it ${DOCKER_CONTAINER_NAME} /bin/bash


echo ""
echo "PC      URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${PC_URL}"
echo ""
echo "MOBILE  URL => ${HTTP_BASE}${SERVER_IP}:${HTTP_PORT}/${MOBILE_URL}"
echo ""

