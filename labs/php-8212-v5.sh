echo "Mfuns build php with swoole and more extensions on ubuntu-22xx, PHP 8.2.12 Swoole v5.1"

base_dir=$(cd "$(dirname "$0")";pwd)

sudo apt update
sudo apt upgrade
sudo apt install git wget autoconf automake bison build-essential curl flex \
  libtool libssl-dev libcurl4-openssl-dev libxml2-dev libreadline8 \
  libreadline-dev libsqlite3-dev libzip-dev openssl \
  pkg-config re2c sqlite3 zlib1g-dev libonig5 libonig-dev libsodium-dev \
  unzip

sudo apt install libboost-all-dev
sudo rm -rf "${base_dir}/tmp/php82"
sudo rm -rf /tmp/pecl/install
sudo rm -rf /tmp/pear/install
mkdir -p "${base_dir}/tmp/php82"
cd "${base_dir}/tmp/php82" || exit
wget https://www.php.net/distributions/php-8.2.12.tar.gz
tar -xzvf php-8.2.12.tar.gz
cd "php-8.2.12" || exit
./configure --prefix=${base_dir}/tmp/php82/php \
     --enable-mysqlnd \
     --with-pdo-mysql \
     --with-pdo-mysql=mysqlnd \
     --enable-bcmath \
     --enable-fpm \
     --enable-mbstring \
     --enable-phpdbg \
     --enable-shmop \
     --enable-sockets \
     --enable-sysvmsg \
     --enable-sysvsem \
     --enable-sysvshm \
     --enable-zip \
     --with-libzip=/usr/lib/x86_64-linux-gnu \
     --with-zlib \
     --with-curl \
     --with-pear \
     --with-openssl \
     --enable-pcntl \
     --with-readline
make -j 12  || exit
make install  || exit
cp php.ini-development ${base_dir}/tmp/php82/php/lib/php.ini

cd "${base_dir}/tmp/php82" || exit
wget https://github.com/swoole/swoole-src/archive/refs/tags/v5.1.0.zip
unzip v5.1.0.zip
cd "swoole-src-5.1.0" || exit
"${base_dir}"/tmp/php82/php/bin/phpize
./configure --enable-openssl --enable-http2 --enable-swoole-curl --enable-swoole-json --with-php-config=${base_dir}/tmp/php82/php/bin/php-config
make -s -j 12
make install

wget http://pear.php.net/go-pear.phar
sudo ${base_dir}/tmp/php82/php/bin/php go-pear.phar
sudo ${base_dir}/tmp/php82/php/bin/pear config-get php_dir

sudo ${base_dir}/tmp/php82/php/bin/pecl channel-update pecl.php.net
#sudo ${base_dir}/tmp/php82/php/bin/pecl install zendopcache
sudo ${base_dir}/tmp/php82/php/bin/pecl install redis
#sudo ${base_dir}/tmp/php82/php/bin/pecl install libsodium

echo "memory_limit=1G" >> ${base_dir}/tmp/php82/php/lib/php.ini
echo "opcache.enable_cli = 'On'" >> ${base_dir}/tmp/php82/php/lib/php.ini
echo "extension=redis.so" >> ${base_dir}/tmp/php82/php/lib/php.ini
#echo "extension=sodium.so" >> ${base_dir}/tmp/php82/php/lib/php.ini
echo "extension=swoole.so" >> ${base_dir}/tmp/php82/php/lib/php.ini
echo "swoole.use_shortname = 'Off'" >> ${base_dir}/tmp/php82/php/lib/php.ini

${base_dir}/tmp/php82/php/bin/php -v
${base_dir}/tmp/php82/php/bin/php -m
${base_dir}/tmp/php82/php/bin/php --ri swoole
#${base_dir}/tmp/php82/php/bin/php --ri yasd

cd ${base_dir}/tmp/php82 || exit
wget https://mirrors.aliyun.com/composer/composer.phar
${base_dir}/tmp/php82/php/bin/php composer.phar

echo -e "\033[42;37m Build Completed :).\033[0m\n"
