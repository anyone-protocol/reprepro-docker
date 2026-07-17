FROM debian:bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  gnupg openssh-server ca-certificates

# Debian reverted the reprepro 5.4.x series (trixie/sid ship "5.4.6+really5.3.2",
# i.e. upstream 5.3.2), but our repository database was created by 5.4.x and
# 5.3.x cannot read it correctly (references.db fails to open; uploads against
# the db are silently dropped). Pin the exact 5.4.3 build this repository has
# been running on, from the immutable Debian snapshot archive. Revisit once
# reprepro >= 5.5 reaches Debian stable (5.5 reads 5.4 databases).
ADD https://snapshot.debian.org/file/e7b301980b265863b1f8188ae9a450a0c2464455 /tmp/reprepro_5.4.3-1_amd64.deb
RUN echo "5081654b61979b5dd2ebef078b15294036dd51c728bcbb17efc261dca91b08ea  /tmp/reprepro_5.4.3-1_amd64.deb" | sha256sum -c - && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  /tmp/reprepro_5.4.3-1_amd64.deb && \
  rm /tmp/reprepro_5.4.3-1_amd64.deb

RUN ssh-keygen -A

RUN mkdir -p /var/run/sshd
RUN echo "REPREPRO_BASE_DIR=/data/debian" > /etc/environment

# Configure an reprepro user (admin)
RUN adduser --system --group --shell /bin/bash --uid 600 --disabled-password --home /home/reprepro reprepro
RUN usermod -p '*' reprepro

# Create required directories
RUN mkdir -p /data/debian/conf
RUN mkdir -p /data/debian/incoming
RUN mkdir -p /data/debian/tmp
RUN mkdir -p /config

ADD sshd_config /sshd_config
ADD run.sh /run.sh
RUN chmod +x /run.sh

ENV GNUPGHOME="/home/reprepro/.gnupg"
ENV REPREPRO_DEFAULT_NAME Reprepro

CMD ["/run.sh"]
