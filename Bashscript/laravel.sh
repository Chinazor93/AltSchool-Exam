#!/bin/bash

#Installing software properties
sudo apt-get install software-properties-common -y

# UPDATING AND UPGRADING SERVER
sudo apt update -y < /dev/null

sudo apt upgrade -y < /dev/null

#LAMP STACK INSTALLATION

#Apache2
sudo apt install apache2 -y < /dev/null
sudo systemctl enable apache2 -y < /dev/null
sudo systemctl start apache2 -y < /dev/null

#MYSQL
sudo apt install mysql-server -y < /dev/null
sudo systemctl enable mysql -y < /dev/null
sudo systemctl start mysql -y < /dev/null

#PHP
sudo add-apt-repository -y ppa:ondrej/php < /dev/null
sudo apt update -y < /dev/null
sudo apt install php libapache2-mod-php php-mysql php-common php-gd php-xml php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip unzip -y < /dev/null
sudo a2enmod php8.2 < /dev/null
sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini

#Restart Apache2
sudo systemctl restart apache2 


# INSTALLING COMPOSER
sudo apt-get install curl -y < /dev/null
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer


# CONFIGURING APACHE WEB SERVER
cat << EOF > /etc/apache2/sites-available/apache.conf 
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

#Enable site
sudo a2enmod rewrite
sudo a2ensite apache.conf

#Restart server to effect changes
sudo systemctl restart apache2

#Install git
sudo apt install -y git

# CLONING LARAVEL FROM GITHUB
cd /var/www/html
sudo git clone https://github.com/laravel/laravel.git

#Run composer to get dependencies
cd /var/www/html/laravel
composer install --no-dev < /dev/null

#Grant permissions for the directory
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache

cd /var/www/html/laravel
sudo cp .env.example .env

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

#Updating the .env file
sudo sed -i 's/DB_DATABASE=laravel/DB_DATABASE=chinazor' /var/www/html/lavarel/.env
sudo sed -i 's/DB_USERNAME=root/DB_USERNAME=chinazor/' /var/www/html/lavarel/.env
sudo sed -i 's/DB_PASSWORD=/DB_PASSWORD=nazor93/' /var/www/html/lavarel/.env

echo "MYSQL user and database created"
echo "USERNAME: $1"
echo "DATABASE: $1"
echo "PASSWORD: $PASS"


#EXECUTING KEYGENERATE AND MIGRATE COMMAND FOR PHP
php artisan key:generate

php artisan cache:clear

php artisan config:cache

php artisan migrate


# restart apache2
sudo systemctl restart apache2

