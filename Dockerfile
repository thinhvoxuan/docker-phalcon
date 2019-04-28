FROM eboraas/debian:stable
MAINTAINER Ed Boraas <ed@boraas.ca>

RUN apt-get update && apt-get install -y build-essential curl gcc make pkg-config libpcre3-dev git
RUN apt-get update && apt-get -y install apache2 

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN /usr/sbin/a2enmod ssl rewrite expires headers

RUN apt-get update && apt-get -y install php php-mysql libapache2-mod-php
RUN /usr/sbin/a2enmod mpm_prefork

RUN /usr/bin/apt-get update && \
    apt-get -y install php-xml php-zip php-dev php-xdebug php-curl php-mysqlnd php-cli php-gd php-mcrypt php-intl php-redis

RUN cd /tmp/ && \
    /usr/bin/git clone --branch v3.0.1 --depth=1 git://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build/ && \
    ./install && \
    /bin/rm -rf /tmp/cphalcon/

RUN cd /tmp/ && \
    curl -O https://imagemagick.org/download/releases/ImageMagick-6.8.9-10.tar.xz && \
    tar xvf ImageMagick-6.8.9-10.tar.xz && \
    cd ImageMagick-6.8.9-10/ && \
    ./configure && \    
     make install && \ 
    ldconfig /usr/local/lib

RUN pecl install imagick-3.4.3 && \
    /bin/echo 'extension=imagick.so' >> /etc/php/7.0/mods-available/imagick.ini && \
    /usr/sbin/phpenmod imagick

RUN /bin/echo 'extension=phalcon.so' > /etc/php/7.0/mods-available/phalcon.ini && \
    /usr/sbin/phpenmod phalcon

WORKDIR /var/www/phalcon/web
RUN /bin/echo '<html><body><h1>It works!</h1></body></html>' > /var/www/phalcon/web/index.html
WORKDIR /var/www/phalcon

RUN /usr/bin/apt-get -y purge git build-essential gcc make &&  \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon 001-phalcon-ssl

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
