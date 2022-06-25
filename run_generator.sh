#!/bin/bash

re='^[0-9]+$'
if [ "$#" -gt 2 ]; then
    echo "ERROR: Too many params. Only threshold, cpus is accepted. \n Exiting Gracefully." >&2; exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "ERROR: No params passed. Needs threshold value to start. \n Exiting Gracefully." >&2; exit 1
fi

THRESHOLD=${1}
if ! [[ ${THRESHOLD} =~ $re ]] ; then
    echo "ERROR: Invalid Threshold. \n Exiting Gracefully." >&2; exit 1
fi

echo "Threshold: ${THRESHOLD}"

CPUS=0
if [ "$#" -ne 2 ]; then
    if ! [ -x "$(command -v nproc)" ]; then
        echo "WARN: nproc not found using /proc/cpuinfo for getting cpu count"
        CPUS=$(grep -c ^processor /proc/cpuinfo)
    else
        CPUS=$(nproc --all)
    fi
else
    CPUS=${2}
    if ! [[ ${CPUS} =~ $re ]] ; then
        echo "ERROR: Invalid CPU value. Resetting to machine CPU's."
        if ! [ -x "$(command -v nproc)" ]; then
            echo "WARN: nproc not found using /proc/cpuinfo for getting cpu count"
            CPUS=$(grep -c ^processor /proc/cpuinfo)
        else
            CPUS=$(nproc --all)
        fi
    fi
fi

echo "CPUS: ${CPUS}"

if [ "${THRESHOLD}" -gt "${CPUS}" ]; then
    echo "Threshold is greater than CPUS. Resetting threshold to ${CPUS}"
    THRESHOLD=${CPUS}
fi

if ! [ -x "$(command -v docker)" ]; then
  echo "Please install docker to run the script. Exiting."
  exit 1
fi

mkdir -p "${HOME}/storj-identies"

storj_identies_home="${HOME}/storj-identies/*"
for identity_folder in ${storj_identies_home}; do
if [ -z "$(ls -A ${identity_folder})" ]; then
   echo -n "${identity_folder} found to be empty. Removing ... "
   rm -rf ${identity_folder}
   echo "Done."
fi
done

random=$(echo $RANDOM | md5sum | head -c 20)
for (( count=1;count<=${THRESHOLD};count++ ))
do
    mkdir -p "${HOME}/storj-identies/${random}"
    dir_to_mount="${HOME}/storj-identies/${random}"
    docker run --rm -d --cpus=1 --name storj-identity-generator-${count} -v ${dir_to_mount}:/app/identity -it bharathappali/storj-identity-generator:latest
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
            docker run --rm -d --cpus=1 --name storj-identity-generator-${count} -v ${dir_to_mount}:/app/identity -it bharathappali/storj-identity-generator:latest
        fi
    done
    echo -n "Sleeping for 60 secs ... "
    sleep 60
    echo "Done."
done