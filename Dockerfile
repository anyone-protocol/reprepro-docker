FROM debian:bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  gnupg reprepro openssh-server

RUN ssh-keygen -A

RUN mkdir /var/run/sshd
RUN echo "REPREPRO_BASE_DIR=/data/debian" > /etc/environment

# Configure an reprepro user (admin)
RUN adduser --system --group --shell /bin/bash --uid 600 --disabled-password --home /home/reprepro reprepro
RUN usermod -p '*' reprepro

ADD sshd_config /sshd_config
ADD run.sh /run.sh
RUN chmod +x /run.sh

ENV GNUPGHOME="/home/reprepro/.gnupg"
ENV REPREPRO_DEFAULT_NAME Reprepro

CMD ["/run.sh"]
