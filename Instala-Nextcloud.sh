#!/bin/bash
###############################################
# Instalação do Nextcloud 13.04 no Debian 9.4 #
###############################################

source variaveis.sh

apt install apache2 php7.0 mariadb-server -y

#(Let’s Encrypt ou)
a2enmod ssl
a2ensite default-ssl

a2enmod rewrite
a2enmod headers

apt install sudo php7.0-mysql php7.0-zip php7.0-xml php7.0-mbstring php7.0-gd php7.0-curl -y
#apt install php7.0-bz2 php7.0-intl php7.0-mcrypt

wget https://download.nextcloud.com/server/releases/nextcloud-13.0.4.tar.bz2
tar -xf nextcloud-13.0.4.tar.bz2
cp -r nextcloud /var/www/nextcloud
chown -R www-data:www-data /var/www/

#echo "Alias /nextcloud "/var/www/nextcloud/"
#
#Directory /var/www/nextcloud/>
#  Options +FollowSymlinks
#  AllowOverride All
#
# <IfModule mod_dav.c>
#  Dav off
# </IfModule>
#
# SetEnv HOME /var/www/nextcloud
# SetEnv HTTP_HOME /var/www/nextcloud
#
#</Directory>" >> /etc/apache2/sites-available/nextcloud.conf

wget https://raw.githubusercontent.com/Corolario/Instala-Nextcloud/master/ubu_ssl.conf -O /etc/apache2/sites-available/nextcloud.conf
wget https://raw.githubusercontent.com/Corolario/Instala-Nextcloud/master/ubu_dom.conf -O /etc/apache2/sites-available/nextcloud-ssl.conf

a2ensite nextcloud
a2ensite nextcloud-ssl

mysql -u root <<CRIA_BD
CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'senha';
CREATE DATABASE IF NOT EXISTS nextcloud;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'usuario'@'localhost';
quit;
CRIA_BD

#apt-get install php-apcu
#apt-get install redis-server php-redis

cd /var/www/nextcloud/
sudo -u www-data php occ  maintenance:install --database "mysql" \
--database-name "nextcloud"  --database-user "usuario" --database-pass "senha" \
--admin-user "ncadmin" --admin-pass "ncsenha"

#sudo -u www-data php occ config:system:set trusted_domains 0 --value=IP_EXTERNO
service apache2 restart

#nano /var/www/nextcloud/config/config.php
#'memcache.local' => '\OC\Memcache\APCu',
#'memcache.locking' => '\OC\Memcache\Redis',
#'redis' => array(
#      'host' => 'localhost',
#      'port' => 6379,
#       ),
