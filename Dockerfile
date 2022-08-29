FROM ubuntu:22.04

# Set program version environment
ENV PHP_VERSION 8.1
ENV MARIADB_VERSION 10.9

# Set misc environment
ENV REGION Asia/Jakarta

# Update repository
RUN apt-get update && apt upgrade -y

# Install base os
RUN apt-get install -y supervisor \
	openssh-server \
	curl \
	sudo \
	dos2unix \
	tzdata \
	apt-transport-https

# Configure servertime
RUN ln -fs /usr/share/zoneinfo/${REGION} /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

# Install nginx
RUN apt-get install -y nginx

# Install php extension
RUN apt-get install -y openssl \
	php-fpm \
	php${PHP_VERSION}-common \
	php${PHP_VERSION}-mysql \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-curl \
	php${PHP_VERSION}-xml \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-zip \
	php${PHP_VERSION}-gd

# Install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
RUN apt-get install -y nodejs

# Create run folder
RUN mkdir -p /var/run/php \
	&& mkdir -p /var/run/sshd

# Output nginx logs to stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# copy supervisor configuration
COPY ./docker/supervisord.conf /etc/supervisord.conf
COPY ./docker/sshd_config /etc/ssh/sshd_config

# Setup root password
RUN echo "root:SSH@2022.ftech"|chpasswd

EXPOSE 22 80

# run supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]