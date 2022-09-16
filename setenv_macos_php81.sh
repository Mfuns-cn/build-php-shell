echo "Set environment variables for PHP 8.1"
base_dir=$(pwd)

sudo ln -s -f ${base_dir}/macos/php81/php/bin/php /usr/local/bin/php
sudo ln -s -f ${base_dir}/macos/php81/composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
echo "Done"