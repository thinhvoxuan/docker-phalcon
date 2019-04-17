FROM eboraas/debian:stable
MAINTAINER Ed Boraas <ed@boraas.ca>

RUN apt-get update && apt-get -y install apache2 && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN /usr/sbin/a2ensite default-ssl
RUN /usr/sbin/a2enmod ssl rewrite expires headers

RUN apt-get update && apt-get -y install php php-mysql libapache2-mod-php && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /usr/sbin/a2enmod mpm_prefork

RUN /usr/bin/apt-get update && apt-get -y install git build-essential curl imagemagick php-xml php-zip php-imagick php-xdebug php-dev php-curl php-mysqlnd php-cli php-gd php-mcrypt php-intl php-redis libpcre3-dev gcc make && \
    /usr/bin/git clone --branch v3.0.1 --depth=1 git://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build/ && \
    ./install && \
    cd /tmp && \
    /bin/rm -rf /tmp/cphalcon/ && \
    /usr/bin/apt-get -y purge git php-dev libpcre3-dev build-essential gcc make && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN /bin/echo 'extension=phalcon.so' > /etc/php/7.0/mods-available/phalcon.ini
RUN /usr/sbin/phpenmod phalcon
WORKDIR /var/www/phalcon/web
RUN /bin/echo '<html><body><h1>It works!</h1></body></html>' > /var/www/phalcon/web/index.html
WORKDIR /var/www/phalcon

ADD 000-phalcon.conf /etc/apache2/sites-available/
ADD 001-phalcon-ssl.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-phalcon 001-phalcon-ssl

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
