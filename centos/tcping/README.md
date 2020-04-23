# centos下安装tcping脚本

**编辑脚本**

```shell
vim tcping.sh
```

```shell
#! /bin/bash

cd /usr/local/src
wget https://raw.githubusercontent.com/weavepub/dev_tools/master/centos/tcping/tcping.c
yum install -y gcc
gcc -o tcping tcping.c
cp tcping /usr/bin
tcping baidu.com 80
```

**运行脚本**

```shell
sh tcping.sh
```

**使用**

```
tcping baidu.com 80
```

