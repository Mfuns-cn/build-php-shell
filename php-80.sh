echo "Mfuns build php with swoole and more extensions on ubuntu-2004"

base_dir=$(cd "$(dirname "$0")";pwd)

sudo apt update
sudo apt install git wget autoconf automake bison build-essential curl flex \
  libtool libssl-dev libcurl4-openssl-dev libxml2-dev libreadline8 \
  libreadline-dev libsqlite3-dev libzip-dev libzip5 nginx openssl \
  pkg-config re2c sqlite3 zlib1g-dev libonig5 libonig-dev

sudo apt install libboost-all-dev
sudo rm -rf "${base_dir}/tmp/php80"
sudo rm -rf /tmp/pecl/install
sudo rm -rf /tmp/pear/install
mkdir -p "${base_dir}/tmp/php80"
cd "${base_dir}/tmp/php80" || exit
wget https://www.php.net/distributions/php-8.0.15.tar.gz
tar -xzvf php-8.0.15.tar.gz
cd "php-8.0.15" || exit
./configure --prefix=${base_dir}/tmp/php80/php \
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
make -j 12
make install
cp php.ini-development ${base_dir}/tmp/php80/php/lib/php.ini
cd "${base_dir}/tmp/php80" || exit
wget https://github.com/swoole/swoole-src/archive/v4.6.7.tar.gz
tar -xzvf v4.6.7.tar.gz
cd "swoole-src-4.6.7" || exit
"${base_dir}"/tmp/php80/php/bin/phpize
./configure --enable-openssl --enable-http2 --enable-swoole-curl --enable-swoole-json --with-php-config=${base_dir}/tmp/php80/php/bin/php-config
make -s -j 12
make install

# build yasd debuger
cd "${base_dir}/tmp/php80" || exit
wget https://github.com/swoole/yasd/archive/refs/tags/v0.3.9.zip
unzip v0.3.9.zip
cd yasd-0.3.9
"${base_dir}"/tmp/php80/php/bin/phpize --clean && \
"${base_dir}"/tmp/php80/php/bin/phpize && \
./configure --with-php-config=${base_dir}/tmp/php80/php/bin/php-config && \
make clean && \
make && \
make install

wget http://pear.php.net/go-pear.phar
sudo ${base_dir}/tmp/php80/php/bin/php go-pear.phar
sudo ${base_dir}/tmp/php80/php/bin/pear config-get php_dir

sudo ${base_dir}/tmp/php80/php/bin/pecl channel-update pecl.php.net
#sudo ${base_dir}/tmp/php80/php/bin/pecl install zendopcache
sudo ${base_dir}/tmp/php80/php/bin/pecl install redis
sudo ${base_dir}/tmp/php80/php/bin/pecl install libsodium

echo "memory_limit=1G" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "opcache.enable_cli = 'On'" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "extension=redis.so" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "extension=sodium.so" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "extension=swoole.so" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "swoole.use_shortname = 'Off'" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "zend_extension=yasd" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "yasd.debug_mode=remote" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "yasd.remote_host=127.0.0.1" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "yasd.remote_port=9000" >> ${base_dir}/tmp/php80/php/lib/php.ini

${base_dir}/tmp/php80/php/bin/php -v
${base_dir}/tmp/php80/php/bin/php -m
${base_dir}/tmp/php80/php/bin/php --ri swoole
${base_dir}/tmp/php80/php/bin/php --ri yasd

cd ${base_dir}/tmp/php80 || exit
wget https://github.com/composer/composer/releases/download/2.2.6/composer.phar
${base_dir}/tmp/php80/php/bin/php composer.phar

echo -e "\033[42;37m Build Completed :).\033[0m\n"
