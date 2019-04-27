FROM php:5.6-apache
MAINTAINER ThinhVoXuan <thinhvoxuan@gmail.com>
RUN apt-get update && apt-get install -y build-essential libpcre3-dev

RUN /usr/sbin/a2enmod ssl rewrite expires headers mpm_prefork

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxml2-dev curl libcurl3 libcurl3-dev libmcrypt-dev mysql-client  && \
    pecl install redis xdebug

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd dom xml curl mcrypt gd intl pdo_mysql && \
    docker-php-ext-enable redis

RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN cd /tmp/ && \
    curl -O https://imagemagick.org/download/releases/ImageMagick-6.8.9-10.tar.xz && \
    tar xvf ImageMagick-6.8.9-10.tar.xz && \
    cd ImageMagick-6.8.9-10/ && \
    ./configure && \    
     make install && \ 
    ldconfig /usr/local/lib

RUN pecl install imagick-3.4.1 \
    && docker-php-ext-enable imagick

WORKDIR /var/www/phalcon/web
RUN /bin/echo '<html><body><h1>It works!</h1></body></html>' > /var/www/phalcon/web/index.html
WORKDIR /var/www/phalcon

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon

EXPOSE 80
EXPOSE 443