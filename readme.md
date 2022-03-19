# 构建适用于 Mfuns Hath 的 PHP 环境
**本脚本仅适用于开发，上线部署请使用项目仓库中的容器脚本。**

**NOTICE 每次执行脚本均会删除所有 tmp 目录的东西 由于偷懒为将编译好的php指定到固定目录或添加是否删除确认 所以请自觉注意下（**

适用环境: ubuntu 20.04

**默认安装**
* swoole 
* redis
* libsodium ( 这是上游 jwt库 强制要求的 事实上早在很久之前这个包已纳入php内核 )
* composer
* yasd swoole官方的调试工具 ( 类型xdebug 对于hyperf是否有用请看自身 )
* Swoole Tracker 官方的内存泄漏检测 ( 仅php80 )

## PHP 8.0 with Swoole
* ``sudo bash php-80.sh`` 一路回车即可
* 请自行将所需php与composer绑定到环境变量
* PHP 位置 ./tmp/phpxx/php/bin/php
* Composer 位置 ./tmp/phpxx/composer.phar

## Set PHP 8.0 Env
* ``sudo bash setenv_php80.sh`` 
* 只软连接了 php 与 composer 俩个必要命令

## PHP 8.1 with Swoole
* ``sudo bash php-81.sh`` 一路回车即可
* 实验性内容 
* hyperf 2.2 绝大多数包未能支持
* libsodium 未能支持 上游 jwt库 也不听网友建议 删除这个没用库的依赖（ 就离谱

## Set PHP 8.1 Env
* ``sudo bash setenv_php81.sh``


