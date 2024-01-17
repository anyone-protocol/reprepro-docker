FROM debian:bookworm

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  devscripts dput gpg nmap openssh-client

RUN mkdir -p /changes
WORKDIR /changes

ENV GNUPGHOME="/root/.gnupg"

ADD run-dput.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
