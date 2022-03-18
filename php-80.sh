echo "Mfuns build php with swoole and more extensions on ubuntu-2004"

base_dir=$(cd "$(dirname "$0")";pwd)

echo "更新依赖"
sudo apt update
sudo apt install git wget autoconf automake bison build-essential curl flex \
  libtool libssl-dev libcurl4-openssl-dev libxml2-dev libreadline8 \
  libreadline-dev libsqlite3-dev libzip-dev libzip5 nginx openssl \
  pkg-config re2c sqlite3 zlib1g-dev libonig5 libonig-dev libsodium-dev

sudo apt install libboost-all-dev

echo "删除旧环境"

sudo rm -rf "${base_dir}/tmp/php80"
sudo rm -rf /tmp/pecl/install
sudo rm -rf /tmp/pear/install

echo "开始编译 php-8.0.15"
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
make -j $(nproc)
make install
cp php.ini-development ${base_dir}/tmp/php80/php/lib/php.ini

echo "开始编译 swoole"
cd "${base_dir}/tmp/php80" || exit
wget https://github.com/swoole/swoole-src/archive/refs/tags/v4.8.7.zip
unzip v4.8.7.zip
cd "swoole-src-4.8.7" || exit
"${base_dir}"/tmp/php80/php/bin/phpize
./configure --enable-openssl --enable-http2 --enable-swoole-curl --enable-swoole-json --with-php-config=${base_dir}/tmp/php80/php/bin/php-config
make -s -j $(nproc)
make install

echo "开始编译 yasd debuger"
# build yasd debuger
cd "${base_dir}/tmp/php80" || exit
wget https://github.com/swoole/yasd/archive/refs/tags/v0.3.9.zip
unzip v0.3.9.zip
cd yasd-0.3.9
"${base_dir}"/tmp/php80/php/bin/phpize --clean && \
"${base_dir}"/tmp/php80/php/bin/phpize && \
./configure --with-php-config=${base_dir}/tmp/php80/php/bin/php-config && \
make clean && \
make -j $(nproc) && \
make install

echo "开始初始化 pecl"
wget http://pear.php.net/go-pear.phar
sudo ${base_dir}/tmp/php80/php/bin/php go-pear.phar
sudo ${base_dir}/tmp/php80/php/bin/pear config-get php_dir

sudo ${base_dir}/tmp/php80/php/bin/pecl channel-update pecl.php.net
#sudo ${base_dir}/tmp/php80/php/bin/pecl install zendopcache

echo "开始安装 redis 与 libsodium(这是上游jwt库强制要求的 事实上这个包已纳入php内核)"
sudo ${base_dir}/tmp/php80/php/bin/pecl install redis
sudo ${base_dir}/tmp/php80/php/bin/pecl install libsodium

echo "修改 phpini"
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
echo "zend_extension=${base_dir}/swoole_tracker80.so" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "apm.enable=1" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "apm.sampling_rate=100" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "apm.enable_memcheck=1" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "tracker.enable_malloc_hook=1" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "tracker.sampling_rate=100" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "tracker.enable_memcheck=1" >> ${base_dir}/tmp/php80/php/lib/php.ini
echo "tracker.enable=0" >> ${base_dir}/tmp/php80/php/lib/php.ini

echo "初始化完成"
${base_dir}/tmp/php80/php/bin/php -v
${base_dir}/tmp/php80/php/bin/php -m
${base_dir}/tmp/php80/php/bin/php --ri swoole
${base_dir}/tmp/php80/php/bin/php --ri yasd


echo "安装 composer "
cd ${base_dir}/tmp/php80 || exit
wget https://mirrors.aliyun.com/composer/composer.phar
${base_dir}/tmp/php80/php/bin/php composer.phar

echo -e "\033[42;37m Build Completed :).\033[0m\n"
