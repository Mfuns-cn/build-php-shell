echo "Set environment variables for PHP 8.2"
base_dir=$(cd "$(dirname "$0")";pwd)

sudo ln -s -f ${base_dir}/tmp/php82/php/bin/php /usr/bin/php
sudo ln -s -f ${base_dir}/tmp/php82/composer.phar /usr/bin/composer
sudo chmod +x /usr/bin/composer
echo "Done"