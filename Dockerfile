FROM geekupvn/docker-phalcon:v3.0.1-DevLog
MAINTAINER Vu Tran <vu.tk@geekup.vn>

#Append xdebug configuration to /etc/php5/mods-available/xdebug.ini
RUN printf "xdebug.remote_enable=1\nxdebug.remote_host=10.254.254.254\nxdebug.remote_port=9001\nxdebug.remote_autostart=1\nxdebug.idekey=\"PHPSTORM\"" >> /etc/php5/mods-available/xdebug.ini

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
