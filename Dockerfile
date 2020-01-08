FROM debian:buster

RUN apt update
RUN apt install --yes --no-install-recommends gnupg ca-certificates sudo adduser locales curl
RUN echo "deb http://deb.debian.org/debian buster contrib" | sudo tee /etc/apt/sources.list.d/debian.list
RUN sudo localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -s /bin/bash --create-home runner
RUN echo 'runner ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER runner
ENV SHELL=/bin/bash \
	USER=runner
WORKDIR /home/runner/

# Copy in CI
#ENV PATH=/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin
RUN curl --show-error --silent --location https://api.bintray.com/orgs/gopasspw/keys/gpg/public.key | sudo apt-key add -
RUN echo "deb https://dl.bintray.com/gopasspw/gopass trusty main" | sudo tee /etc/apt/sources.list.d/gopass.list
RUN sudo apt update
RUN sudo apt install --yes --no-install-recommends gopass
RUN curl --show-error --silent --location https://raw.githubusercontent.com/cyberark/summon/master/install.sh | sudo bash
RUN gopass setup --remote git@github.com:camptocamp/geospatial-ci-pass.git --alias gs-ci --name "Stéphane Brunner" --email "stephane.brunner@camptocamp.com"
# End: Copy in CI

# Test: https://cyberark.github.io/summon/
COPY secret.yaml ./
RUN summon | test $TEST = toto
