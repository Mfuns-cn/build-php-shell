# 构建适用于 Mfuns Hath 的 PHP 环境
**本脚本仅适用于开发，上线部署请使用项目仓库中的容器脚本。**

适用环境: ubuntu 20.04

## PHP 8.0 with Swoole
* ``bash php-80.sh`` 一路回车即可
* 请自行将所需php与composer绑定到环境变量
* PHP 位置 ./tmp/phpxx/php/bin/php
* Composer 位置 ./tmp/phpxx/composer.phar

## Set PHP 8.0 Env
* ``bash setenv_php80.sh`` 
* 只软连接了 php 与 composer 俩个必要命令


我只在装好基础环境的wsl ubuntu2004上测试过 所以可能会因为少点啥包 炸掉 请自行百度查阅后提issue(( 永远十七岁青春美少女会很感激的