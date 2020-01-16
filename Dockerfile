FROM php:5.6-apache

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
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN update-locale LANG=en_US.UTF-8
RUN echo "export LANG=en_US.UTF-8\nexport LANGUAGE=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8\nexport PYTHONIOENCODING=UTF-8" | tee -a /etc/bash.bashrc
RUN apt-get install libmcrypt-dev python-pip gcc g++ make librabbitmq-dev libbz2-dev libicu-dev libxml2-dev libxslt1-dev libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev git unzip vim openssh-server ocaml expect curl libssl-dev libcurl4-openssl-dev pkg-config -y
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install \
    bcmath bz2 calendar curl dom 
RUN docker-php-ext-install ftp gd  
RUN docker-php-ext-install json mbstring mcrypt mysqli opcache pdo pdo_mysql 
RUN docker-php-ext-install simplexml soap wddx xml xsl zip
RUN pecl install amqp && docker-php-ext-enable amqp
RUN apt-get install gnupg2 gnupg -y
RUN apt-get install net-tools openssh-server nano vim mysql-client -y && apt-get install -y apache2 \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi\
    && a2enmod ssl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN rm /etc/apache2/sites-available/000-default.conf
ADD extrafiles/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN curl http://browscap.org/stream?q=Full_PHP_BrowsCapINI >> "/usr/local/etc/php/browscap.ini"
ADD extrafiles/php.ini /usr/local/etc/php
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN chmod +x nodesource_setup.sh && ./nodesource_setup.sh
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install sshpass nodejs yarn -y
RUN npm install -g sass less grunt
RUN mkdir /ssl
RUN openssl req -new -x509 -days 365 -keyout /ssl/privkey.pem -out /ssl/cert.pem -nodes -subj  '/O=VirtualHost Website Company name/OU=Virtual Host Website department/CN=backend.local.com'
RUN groupmod -g $(id -u  ${LOCAL_USER}) www-data

WORKDIR /var/www/html

EXPOSE 80 443
