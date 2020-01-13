FROM debian:buster

RUN apt update
RUN apt install --yes --no-install-recommends gnupg ca-certificates sudo adduser locales curl
RUN echo "deb http://deb.debian.org/debian buster contrib" | sudo tee /etc/apt/sources.list.d/debian.list
RUN sudo localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -s /bin/bash --create-home runner
RUN echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /usr/local/bin/
RUN chmod 777 /usr/local/bin/
USER runner
ENV SHELL=/bin/bash \
	USER=runner
WORKDIR /home/runner/
COPY CI.asc .
RUN gpg --import CI.asc

# Copy in CI
ENV GOPASS_VERSION=1.8.6 \
    SUMMON_VERSION=0.8.0
#ENV PATH=/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin
# Install gopass
RUN curl --show-error --silent --location \
  https://github.com/gopasspw/gopass/releases/download/v${GOPASS_VERSION}/gopass-${GOPASS_VERSION}-linux-amd64.tar.gz \
  -o - | tar xz gopass-${GOPASS_VERSION}-linux-amd64/gopass -O > /usr/local/bin/gopass && \
  chmod +x /usr/local/bin/gopass
# Install summon
RUN curl --show-error --silent --location \
  https://github.com/cyberark/summon/releases/download/v${SUMMON_VERSION}/summon-linux-amd64.tar.gz \
  -o - | tar xz summon -O > /usr/local/bin/summon && \
  chmod +x /usr/local/bin/summon

RUN gopass init --store gs/ci
RUN gopass git remote add --store gs/ci origin git@github.com:camptocamp/geospatial-ci-pass.git
#RUN gopass setup --remote git@github.com:camptocamp/geospatial-ci-pass.git --alias gs-ci --name "Stéphane Brunner" --email "stephane.brunner@camptocamp.com"
# End: Copy in CI

# Test: https://cyberark.github.io/summon/
COPY secret.yaml ./
RUN summon | test $TEST = toto
