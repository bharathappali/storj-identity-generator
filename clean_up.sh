#!/bin/bash

docker ps --filter name=storj-identity-generator-* --filter status=running -aq | xargs docker stop

storj_identies_home="${HOME}/storj-identies/*"
for identity_folder in ${storj_identies_home}; do
if [ -z "$(ls -A ${identity_folder})" ]; then
    echo -n "${identity_folder} found to be empty. Removing ... "
    rm -rf ${identity_folder}
    echo "Done."
fi
done
