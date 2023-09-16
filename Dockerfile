FROM php:7.4-apache

LABEL maintainer="guillermortega1e@gmail.com"

ENV SERVER_NAME "localhost"
ENV WEBSERVER_USER "www-data"
ENV LOCAL_USER "local"
ENV IDEKEY "PHPSTORM"
ENV REMOTEPORT "9000"

RUN groupadd localGroup -g 3000
RUN useradd -g 3000 -m -d /home/${LOCAL_USER} -s /bin/bash ${LOCAL_USER} && usermod -g www-data ${LOCAL_USER} 
RUN mkdir /home/$LOCAL_USER/.ssh
RUN passwd ${LOCAL_USER} -d
RUN groups ${LOCAL_USER}

RUN apt-get update && apt-get install -y --no-install-recommends locales wget apt-utils tcl build-essential -y
RUN set -x; \
    locale-gen es_MX.UTF-8 && \
    update-locale && \
    echo 'LANG="es_MX.UTF-8"' > /etc/default/locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen en_US.UTF-8
#RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN update-locale LANG=en_US.UTF-8
RUN echo "export LANG=en_US.UTF-8\nexport LANGUAGE=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8\nexport PYTHONIOENCODING=UTF-8" | tee -a /etc/bash.bashrc

RUN apt-get install -y zip unzip sshpass libzip-dev libonig-dev xvfb libxi6 libgconf-2-4 telnet gcc g++ make librabbitmq-dev libbz2-dev libicu-dev libxml2-dev \
    libxslt1-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev git vim openssh-server ocaml expect curl libssl-dev libcurl4-openssl-dev pkg-config
# RUN apt-get install -y python-pip 
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install \
    bcmath bz2 calendar curl dom ftp gd intl json mbstring mysqli opcache pdo pdo_mysql simplexml soap xml xsl zip
RUN apt install libmemcached-dev libmemcached11 -y && pecl install memcached && docker-php-ext-enable memcached
RUN pecl install amqp && docker-php-ext-enable amqp
# RUN pecl install xdebug && docker-php-ext-enable xdebug \
#     && echo "xdebug.idekey = ${IDEKEY}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.remote_port = ${REMOTEPORT}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.remote_enable = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.remote_autostart = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.remote_connect_back = off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.remote_handler = dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.profiler_output_dir = '/var/www/html'" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.collect_params = 4" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.collect_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.dump_globals = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.dump.SERVER = REQUEST_URI" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.show_local_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && echo "xdebug.cli_color = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#     && chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN apt-get install gnupg2 gnupg -y
RUN apt-get install net-tools openssh-server nano vim mariadb-client -y && apt-get install -y apache2 \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi\
    && a2enmod ssl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN rm /etc/apache2/sites-available/000-default.conf
ADD extrafiles/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD extrafiles/php.ini /usr/local/etc/php
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN chmod +x nodesource_setup.sh && ./nodesource_setup.sh
RUN apt-get install nodejs yarn -y
RUN npm install -g sass less grunt
RUN groupmod -g $(id -u  ${LOCAL_USER}) www-data
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1

WORKDIR /var/www/html

EXPOSE 80 443
