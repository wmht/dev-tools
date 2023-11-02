## iperf 测速工具

### 说明

测试两地直接的网络速度



### 配置

1.把iperf文件夹放到D盘根目录
2.进入cmd命令提示行：Win+R输入cmd回车
3.输入D:    回车
4.输入cd iperf     回车



### 启动服务端

在一台电脑（Server）上，输入下面命令，会监听 5201 端口

```sh
iperf3 -s
```





### 测试速度

在另一台电脑（Slave）上

```sh
# 下行(Slave -> Server)
iperf3 -c 10.41.129.135

# 上行(Server -> Slave)
iperf3 -c 10.41.129.135 -R
```



![./img/iperf.png](../../../../WorkNotes/img/iperf.png)

