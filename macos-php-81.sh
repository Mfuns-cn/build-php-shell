echo "Mfuns build php with swoole and more extensions on macos"

brew install wget autoconf automake libtool re2c bison pkg-config openssl libiconv oniguruma readline pcre2

base_dir=$(cd "$(dirname "$0")";pwd)

sudo rm -rf ${base_dir}"/macos-build/php81"
sudo rm -rf /tmp/pecl/install
sudo rm -rf /tmp/pear/install
mkdir -p ${base_dir}"/macos-build/php81"
cd ${base_dir}"/macos-build/php81" || exit

wget https://www.php.net/distributions/php-8.1.27.tar.gz || exit
tar -xzvf php-8.1.27.tar.gz

cd "php-8.1.27" || exit

./configure --prefix="${base_dir}"/macos-build/php81/php \
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
make -j $(sysctl -n hw.ncpu)
make install

cp php.ini-development ${base_dir}/macos-build/php81/php/lib/php.ini
export PATH=${base_dir}"/macos-build/php81/php/bin:$PATH"

cd "${base_dir}/macos-build/php81" || exit
wget https://github.com/swoole/swoole-src/archive/refs/tags/v5.1.2.zip
unzip v5.1.2.zip
cd "swoole-src-5.1.2" || exit
"${base_dir}"/macos-build/php81/php/bin/phpize

ln -s $(brew --prefix pcre2)/include/pcre2.h "${base_dir}"/macos-build/php81/php/include/php/ext/pcre/pcre2.h
./configure \
  --enable-openssl \
  --with-openssl-dir=$(brew --prefix openssl) \
  --enable-http2 \
  --enable-swoole-curl \
  --enable-swoole-json \
  --enable-thread-context \
  --with-php-config=${base_dir}/macos-build/php81/php/bin/php-config

make -j $(sysctl -n hw.ncpu)
make install

cd "${base_dir}"/macos-build/php81
wget http://pear.php.net/go-pear.phar
sudo ${base_dir}/macos-build/php81/php/bin/php go-pear.phar
sudo ${base_dir}/macos-build/php81/php/bin/pear config-get php_dir

sudo ${base_dir}/macos-build/php81/php/bin/pecl channel-update pecl.php.net
sudo ${base_dir}/macos-build/php81/php/bin/pecl install redis

echo "memory_limit=1G" >> "${base_dir}"/macos-build/php81/php/lib/php.ini
echo "opcache.enable_cli = 'On'" >> "${base_dir}"/macos-build/php81/php/lib/php.ini
echo "extension=redis.so" >> "${base_dir}"/macos-build/php81/php/lib/php.ini
echo "extension=swoole.so" >> "${base_dir}"/macos-build/php81/php/lib/php.ini
echo "swoole.use_shortname = 'Off'" >> "${base_dir}"/macos-build/php81/php/lib/php.ini

"${base_dir}"/macos-build/php81/php/bin/php -v
"${base_dir}"/macos-build/php81/php/bin/php -m
"${base_dir}"/macos-build/php81/php/bin/php --ri swoole

cd ${base_dir}/macos-build/php81 || exit
wget https://mirrors.aliyun.com/composer/composer.phar
"${base_dir}"/macos-build/php81/php/bin/php composer.phar

echo -e "\033[42;37m Build Completed :).\033[0m\n"