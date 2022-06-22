#!/bin/bash

if ! [ -x "$(command -v identity)" ]; then
  echo "Please install identity. Exiting."
  exit 1
fi

if ! [ -d "/app/identity" ]; then
    echo "Directory /app/identity doesn't exists."
    echo "Please mount the folder you expect the identity to /app/identity before running the container. Exiting"
    exit 1 
fi

identity create storagenode
mv /root/.local/share/storj/identity/* /app/identity/
