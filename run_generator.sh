#!/bin/bash

if ! [ -x "$(command -v docker)" ]; then
  echo "Please install docker to run the script. Exiting."
  exit 1
fi

THRESHOLD=4
random=$(echo $RANDOM | md5sum | head -c 20)
for (( count=1;count<=${THRESHOLD};count++ ))
do
    mkdir -p "${HOME}/storj-identies/${random}"
    dir_to_mount="${HOME}/storj-identies/${random}"
    docker run --rm -d --name storj-identity-generator-${count} -v ${dir_to_mount}:/app/identity -it bharathappali/storj-identity-generator:latest
    random=$(echo $RANDOM | md5sum | head -c 20)
done
for (( ; ; ))
do
    for (( count=1;count<=${THRESHOLD};count++ ))
    do
        CONTAINER_NAME="storj-identity-generator-${count}"
        # Checking if docker container with $CONTAINER_NAME name exists.
        COUNT=$(docker ps -a | grep "${CONTAINER_NAME}" | wc -l)
        if [ ${COUNT} -eq 0 ]; then
            echo "Launching container - storj-identity-generator-${count}"
            random=$(echo $RANDOM | md5sum | head -c 20)
            mkdir -p "${HOME}/storj-identies/${random}"
            dir_to_mount="${HOME}/storj-identies/${random}"
            docker run --rm -d --name storj-identity-generator-${count} -v ${dir_to_mount}:/app/identity -it bharathappali/storj-identity-generator:latest
        fi
    done
    echo -n "Sleeping for 60 secs ... "
    sleep 60
    echo "Done."
done