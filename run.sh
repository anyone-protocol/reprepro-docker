#!/bin/bash

set -m

chown 600:root /config/reprepro-sec.gpg
chown 600:root /config/reprepro-pub.gpg
chown -R reprepro:reprepro /data/debian

perms=$(stat -c %a /config/reprepro-sec.gpg)
if [ "${perms: -1}" != "0" ]
then
    echo "/config/reprepro-sec.gpg gnupg private key should not be readable by others..."
    echo "=> Aborting!"
    exit 1
fi

gpg --allow-secret-key-import --import /config/reprepro-sec.gpg
if [ $? -ne 0 ]; then
    echo "=> Failed to import gnupg private key for reprepro..."
    echo "=> Aborting!"
    exit 1
fi

chown -R reprepro:reprepro ${GNUPGHOME}

echo "=> Starting SSH server..."
exec /usr/sbin/sshd -f /sshd_config -D -e
