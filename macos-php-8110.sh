echo "Mfuns build php with swoole and more extensions on macos"

brew install wget autoconf automake libtool re2c bison pkg-config openssl libiconv oniguruma readline pcre2

# shellcheck disable=SC2046
sudo rm -rf $(pwd)"/macos/php81"
sudo rm -rf /tmp/pecl/install
sudo rm -rf /tmp/pear/install
mkdir -p $(pwd)"/macos/php81"
cd $(pwd)"/macos/php81" || exit

wget https://www.php.net/distributions/php-8.1.10.tar.gz
tar -xzvf php-8.1.10.tar.gz

cd "php-8.1.10" || exit

# shellcheck disable=SC2046
./configure --prefix="$(pwd)"/macos/php81/php \
  --with-external-pcre=$(brew --prefix pcre2) \
  --with-openssl=$(brew --prefix openssl) \
  --with-iconv=$(brew --prefix libiconv) \
  --with-readline=$(brew --prefix readline) \
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
  --with-zlib \
  --with-curl \
  --with-pear \
  --enable-pcntl

# shellcheck disable=SC2046
make -j $(sysctl -n hw.ncpu)
make install

cp php.ini-development $(pwd)/macos/php81/php/lib/php.ini
cd "$(pwd)/macos/php81" || exit
wget https://github.com/swoole/swoole-src/archive/refs/tags/v4.8.7.zip
unzip v4.8.7.zip
cd "swoole-src-4.8.7" || exit
"${base_dir}"/tmp/php81/php/bin/phpize
# shellcheck disable=SC2086
# shellcheck disable=SC2046
ln -s $(brew --prefix pcre2)/include/pcre2.h "$(pwd)"/macos/php81/php/include/php/ext/pcre/pcre2.h
./configure \
  --enable-openssl \
  --with-openssl-dir=$(brew --prefix openssl) \
  --enable-http2 \
  --enable-swoole-curl \
  --enable-swoole-json \
  --enable-thread-context \
  --with-php-config=$(pwd)/macos/php81/php/bin/php-config

# shellcheck disable=SC2046
make -j $(sysctl -n hw.ncpu)
make install

export PATH=$(pwd)"/macos/php81/php/bin:$PATH"

wget http://pear.php.net/go-pear.phar
sudo php go-pear.phar
sudo pear config-get php_dir

sudo pecl channel-update pecl.php.net
sudo pecl install redis

echo "memory_limit=1G" >> $(pwd)/macos/php81/php/lib/php.ini
echo "opcache.enable_cli = 'On'" >> $(pwd)/macos/php81/php/lib/php.ini
echo "extension=redis.so" >> $(pwd)/macos/php81/php/lib/php.ini
echo "extension=swoole.so" >> $(pwd)/macos/php81/php/lib/php.ini
echo "swoole.use_shortname = 'Off'" >> $(pwd)/macos/tmp/php81/php/lib/php.ini

php -v
php -m
php --ri swoole

cd $(pwd)/macos/php81 || exit
wget https://mirrors.aliyun.com/composer/composer.phar
php composer.phar

echo -e "\033[42;37m Build Completed :).\033[0m\n"
