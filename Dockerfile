FROM debian:bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  gnupg openssh-server ca-certificates

RUN echo "deb https://deb.debian.org/debian experimental main" >> /etc/apt/sources.list
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  reprepro

RUN ssh-keygen -A

RUN mkdir /var/run/sshd
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
