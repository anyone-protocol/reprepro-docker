#!/bin/bash

set -m

export GNUPGHOME="/data/.gnupg"

chown 600:root /config/reprepro_sec.gpg
chown 600:root /config/reprepro_pub.gpg
chown -R reprepro:reprepro /data/debian

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
if [ -d "${GNUPGHOME}" ]
then
    echo "=> /data/.gnupg directory already exists:"
    echo "   So gnupg seems to be already configured, nothing to do..."
else
    echo "=> /data/.gnupg directory does not exist:"
    echo "   Configuring gnupg for reprepro user..."
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
    chown -R reprepro:reprepro ${GNUPGHOME}
fi

echo "=> Starting SSH server..."
exec /usr/sbin/sshd -f /sshd_config -D -e
