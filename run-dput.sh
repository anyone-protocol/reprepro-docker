#!/bin/bash

set -m

export GNUPGHOME="/root/.gnupg"

chown 600:root /config/reprepro_sec.gpg

if [ -f "/config/reprepro_sec.gpg" ]
then
    perms=$(stat -c %a /config/reprepro_sec.gpg)
    if [ "${perms: -1}" != "0" ]
    then
        echo "/config/reprepro_sec.gpg gnupg private key should not be readable by others..."
        echo "=> Aborting!"
        exit 1
    fi
fi

gpg --import /config/reprepro_pub.gpg
if [ $? -ne 0 ]; then
    echo "=> Failed to import gnupg public key for reprepro..."
    echo "=> Aborting!"
    exit 1
fi

gpg --allow-secret-key-import --import /config/reprepro_sec.gpg
if [ $? -ne 0 ]; then
    echo "=> Failed to import gnupg private key for reprepro..."
    echo "=> Aborting!"
    exit 1
fi

chown -R root:root ${GNUPGHOME}

exec sleep infinity
