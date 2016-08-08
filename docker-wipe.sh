#!/bin/bash
#
# delete all docker container and images

SUDO=sudo

#~ FILTER="head -1"
FILTER="cat"

df -h /

# first kill all which are still running, then delete all containers, then all images
$SUDO docker ps    --format "$SUDO docker kill '{{.ID}}'" | $FILTER | bash &&
$SUDO docker ps -a --format "$SUDO docker rm   '{{.ID}}'" | $FILTER | bash &&
$SUDO docker rmi $($SUDO docker images -q -a | $FILTER)

#~ $SUDO docker ps --format "echo sudo docker kill '{{.ID}}'" | head -1
#~ $SUDO docker ps -a --format "echo $SUDO docker rm '{{.ID}}'" | head -1
#~ sudo docker rmi $(sudo docker images -q -a | head -1)

df -h /
