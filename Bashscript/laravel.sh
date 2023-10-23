#!/bin/bash


# UPDATING AND UPGRADING SERVER
sudo apt update -y

sudo apt upgrade -y < /dev/null

#LAMP STACK INSTALLATION
sudo apt install apache2 -y < /dev/null

sudo apt mysql-server -y < /dev/null

sudo add-apt-repository -y ppa:ondrej/php < /dev/null

sudo apt update < /dev/null

sudo apt install php libapache2-mod-php php-mysql php-common php-gd php-xml php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip unzip -y < /dev/null

sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini

sudo systemctl restart apache2 < /dev/null


# INSTALLING COMPOSER

sudo apt-get install curl -y
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer


# CONFIGURING APACHE WEB SERVER
cat << EOF /etc/apache2/sites-available/apache.conf> 
<VirtualHost *:80>

    ServerAdmin echedikechinazor@gmail.com
    ServerName 192.168.20.17
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
       Options +FollowSymlinks
       AllowOverride All
       Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

sudo a2enmod rewrite

sudo a2ensite apache.conf

sudo systemctl restart apache2

# CLONING LARAVEL FROM GITHUB
cd /var/www/html
git clone https://github.com/laravel/laravel.git .

cd /var/www/html/laravel
composer install --no-dev < /dev/null

sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache

cd /var/www/html/laravel
cp .env.example .env

php artisan key:generate


# CONFIGURING MySQL
PASS=$2
if [ -z "$2" ]; then
PASS='openssl rand -base64 6'
fi

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE $1;
CREATE USER '$1'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEDGES ON $1.* TO '$1'@'localhost';
FLUSH PRIVILEDGES;
MYSQL_SCRIPT


# EXECUTING KEYGENERATE AND MIGRATE COMMAND FOR PHP

sudo sed -i 's/DB_DATABASE=laravel/DB_DATABASE=chinazor' /var/www/html/lavarel/.env
sudo sed -i 's/DB_USERNAME=root/DB_USERNAME=chinazor/' /var/www/html/lavarel/.env
sudo sed -i 's/DB_PASSWORD=/DB_PASSWORD=nazor93/' /var/www/html/lavarel/.env

php artisan config:cache

cd /var/www/html/laravel
php artisan migrate
