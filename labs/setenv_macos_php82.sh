echo "Set environment variables for PHP 8.2"
base_dir=$(pwd)

sudo ln -s -f ${base_dir}/macos/php82/php/bin/php /usr/local/bin/php
sudo ln -s -f ${base_dir}/macos/php82/composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
echo "Done"