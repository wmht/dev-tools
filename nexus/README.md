**1、清理 neuxs docker 镜像脚本**

**2、手动编译生成的 nexus-cli 工具**



nexus-cli 工具下载：[github地址](https://github.com/mlabouardy/nexus-cli)

github中提供的 nexus-cli 工具清理逻辑有问题，比如镜像含有如下12个tag

```
build-8
build-9
build-89
build-90
...
build-100
```

最先删除的是 build-100，而不是删除 build-8。正确的逻辑应该是先删除 build-8、build-9，最后删除 build-100。查看源码发现逻辑是正确的，遂下载源码，重新编译生成 nexus-cli 文件。