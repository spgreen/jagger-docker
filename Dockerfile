FROM php:7.3-apache

ENV CI_Version=3.1.10
ENV JAGGER_Version=v1.8.0

RUN apt update && apt upgrade -y && \
    cd /opt && \
    apt install -y libxml2-dev libmcrypt-dev libmemcached-dev librabbitmq-dev zlib1g-dev wget unzip git && \
    docker-php-ext-install pdo_mysql opcache xml bcmath && \
    pecl install mcrypt-1.0.2 memcached-3.1.3 amqp-1.9.4 && \
    docker-php-ext-enable mcrypt memcached amqp && \
    curl -sS https://getcomposer.org/installer | php && \
    cp composer.phar /usr/bin/composer && \
    rm composer.phar && \
    sed -ie  's/memory_limit = .*/memory_limit = 256M/g' /usr/local/etc/php/php.ini-production && \
    sed -ie 's/max_execution_time = .*/max_execution_time = 60/g' /usr/local/etc/php/php.ini-production && \
    wget https://github.com/bcit-ci/CodeIgniter/archive/${CI_Version}.zip && \
    unzip ${CI_Version}.zip && \
    mv CodeIgniter-${CI_Version} codeigniter && \
    rm ${CI_Version}.zip && \
    git clone https://github.com/Edugate/Jagger /opt/rr3 && \
    cd /opt/rr3 && \
    git checkout ${JAGGER_Version} && \
    cd /opt/rr3/application && \
    composer install && \
    cp /opt/codeigniter/index.php /opt/rr3/ && \
    cd /opt/rr3 && \
    chgrp www-data /opt/rr3/application/models/Proxies && \
    chmod 775 /opt/rr3/application/models/Proxies && \
    chgrp www-data /opt/rr3/application/cache && \
    chmod 775 /opt/rr3/application/cache && \
    mkdir /var/log/rr3 && \
    chown www-data.www-data /var/log/rr3 && \
    chmod 750 /var/log/rr3 && \
    sed -ie "s/$system_path = 'system';/$system_path = '\/opt\/codeigniter\/system';/g" index.php && \
    sed -ie "56i\\\t\$_SERVER['CI_ENV'] = 'production';" index.php && \
    ./install.sh && \
    cd application/config && \
    a2enmod rewrite && \
    a2enmod headers && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY config/config.php /opt/rr3/application/config
COPY config/config_rr.php /opt/rr3/application/config
COPY config/database.php /opt/rr3/application/config
COPY config/memcached.php /opt/rr3/application/config
COPY config/apache.conf /etc/apache2/sites-available/000-default.conf
COPY config/apache_security.conf /etc/apache2/conf-available/security.conf
COPY scripts /opt/scripts
COPY run.sh /opt/run.sh

WORKDIR /opt/

CMD ["./run.sh"]
