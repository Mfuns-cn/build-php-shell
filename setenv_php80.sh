echo "Set environment variables for PHP 8.0"
base_dir=$(cd "$(dirname "$0")";pwd)

sudo ln -s -f ${base_dir}/tmp/php80/php/bin/php /usr/bin/php
sudo ln -s -f ${base_dir}/tmp/php80/composer.phar /usr/bin/composer
sudo chmod +x /usr/bin/composer
echo "Done"