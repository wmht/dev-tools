#! /bin/bash
## 执行脚本之前，先配置好 kubeconfig 文件，存放在用户家目录的 .kube 目录下.
## kubeconfig 文件中，上下文中对应环境的名字必须为 dev 与 prod.

stty erase ^H
clear
## define echo terminal style
export ECHO_STYLE_00="\033[0m"
export ECHO_STYLE_02="\033[42;1m"
export ECHO_STYLE_04="\033[32;1m"
echo " "
echo -e "${ECHO_STYLE_04}          请输入对应的序号，查看资源统计${ECHO_STYLE_00}"

# 1、CPU
cpu(){
read -p "请输入需要查询的环境，如：prod、dev : " e
rancher_env=$e

kubectl --context $rancher_env top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .top.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} $rancher_env 环境, Pod 占用 CPU 排行                                                  ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .top.txt |sort -k 3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} $rancher_env 环境, 各项目的 Pod 占用 CPU 排行                                            ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .top.txt |sort -k1,1 -k3,3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} $rancher_env 环境，各项目占用 CPU 排行               ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加，
cat .top.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 2nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .top.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .top.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
rm -rf .top.txt
}

# 2、内存
memory(){
read -p "请输入需要查询的环境，如：prod、dev : " e
rancher_env=$e

kubectl --context $rancher_env top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .memory.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} $rancher_env 环境 Memory 排行                                                           ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .memory.txt |sort -k 4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} $rancher_env 环境, 各项目的 Pod 占用 Memory 排行                                          ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .memory.txt |sort -k1,1 -k4,4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} $rancher_env 环境，各项目占用 Memory 排行              ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加
cat .memory.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 3nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .memory.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .memory.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
rm -rf .memory.txt
}


# 3、统计平均值等信息
# 从prometheus http_api获取相对应数据：
# http://api-prometheus-operated.qaz123.wmqhealth.com/api/v1/query?query=container_memory_working_set_bytes{namespace="standard-data",container_name!="",container_name!="POD",pod="standard-data-server-765477df7-84zwj"}[5m]
# curl -s -g 'http://api-prometheus-operated-prod.qaz123.wmqhealth.com/api/v1/query?query=container_cpu_usage_seconds_total{node="prod-k8s-worker-server-05",container_name!="",container_name!="POD"}'|jq '.data.result'|jq '.[].metric'
# curl 参数说明：
#              -s 去除提醒信息
#              -g 不用转义
#         
# 定义变量
functions_max='max_over_time'
functions_avg='avg_over_time'
functions_current_cpu='container_cpu_usage_seconds_total'
functions_current_memory='container_memory_working_set_bytes'
functions_requests_cpu='kube_pod_container_resource_requests_cpu_cores'
functions_limits_cpu='kube_pod_container_resource_limits_cpu_cores'
functions_requests_memory='kube_pod_container_resource_requests_memory_bytes'
functions_limits_memory='kube_pod_container_resource_limits_memory_bytes'
# 函数体
max_avg(){
read -p "请输入需要查询的平均时间，如：5m、5h、5d等 : " f
read -p "请输入需要查询的环境，如：prod、dev : " e
over_time=$f
rancher_env=$e
echo ""
echo -e "${ECHO_STYLE_04} 正在查询中...... ${ECHO_STYLE_00}"
kubectl --context $rancher_env top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .top.txt
echo "环境 命名空间 POD名称 实时CPU '$over_time'最大CPU '$over_time'平均CPU 预留CPU 限制CPU 实时内存 '$over_time'最大内存 '$over_time'平均内存 预留内存 限制内存" > .avg.txt
echo "---- -------- ------- ------- ----------- ----------- ------- ------- -------- ------------ ------------ -------- --------" >>.avg.txt
cat .top.txt |while read line
do
    if [ $rancher_env = "dev" ]
    then
      url='http://api-prometheus-operated.qaz123.wmqhealth.com/api/v1/query?query='
    else
      url='http://api-prometheus-operated-prod.qaz123.wmqhealth.com/api/v1/query?query='
    fi
    namespace=`echo "${line}" |awk '{print $1}'`
    pod=`echo "${line}" |awk '{print $2}'`
    # 转换成json数据
    # CPU
    current_cpu_json_data=`curl -s ''$url''$functions_current_cpu'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}'`
    max_cpu_json_data=`curl -s ''$url''$functions_max'('$functions_current_cpu'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}\['$over_time'\])'`
    avg_cpu_json_data=`curl -s ''$url''$functions_avg'('$functions_current_cpu'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}\['$over_time'\])'`
    requests_cpu_json_data=`curl -s ''$url''$functions_requests_cpu'\{namespace="'${namespace}'",pod="'${pod}'"\}'`
    limits_cpu_json_data=`curl -s ''$url''$functions_limits_cpu'\{namespace="'${namespace}'",pod="'${pod}'"\}'`
    # 内存
    current_memory_json_data=`curl -s ''$url''$functions_current_memory'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}'`
    max_memory_json_data=`curl -s ''$url''$functions_max'('$functions_current_cpu'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}\['$over_time'\])'`
    avg_memory_json_data=`curl -s ''$url''$functions_avg'('$functions_current_cpu'\{namespace="'${namespace}'",container_name!="",container_name!="POD",pod="'${pod}'"\}\['$over_time'\])'`
    requests_memory_json_data=`curl -s ''$url''$functions_requests_memory'\{namespace="'${namespace}'",pod="'${pod}'"\}'`
    limits_memory_json_data=`curl -s ''$url''$functions_limits_memory'\{namespace="'${namespace}'",pod="'${pod}'"\}'`

    # 过滤json数据
    # CPU
    # 瞬时最大平均值都有两组相同数值，只取第一个（jq '.[1].value'）。预留和限制值只有一个就不用过滤（jq '.[].value'）。
    current_cpu=`echo "$current_cpu_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]' |sed "s/\..*//g"`
    max_cpu=`echo "$max_cpu_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]' |sed "s/\..*//g"`
    avg_cpu=`echo "$avg_cpu_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]' |sed "s/\..*//g"`
    requests_cpu=`echo "$requests_cpu_json_data"|jq '.data.result'|jq '.[].value'|jq -r '.[1]'`
    limits_cpu=`echo "$limits_cpu_json_data"|jq '.data.result'|jq '.[].value'|jq -r '.[1]'`
    # 内存
    current_memory=`echo "$current_memory_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]'`
    max_memory=`echo "$max_memory_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]' |sed "s/\..*//g"`
    avg_memory=`echo "$avg_memory_json_data"|jq '.data.result'|jq '.[1].value'|jq -r '.[1]' |sed "s/\..*//g"`
    requests_memory=`echo "$requests_memory_json_data"|jq '.data.result'|jq '.[].value'|jq -r '.[1]'`
    limits_memory=`echo "$limits_memory_json_data"|jq '.data.result'|jq '.[].value'|jq -r '.[1]'`

    # 处理CPU数据
    if [[ $requests_cpu = "" || $limits_cpu = "" ]]
    then
      requests_cpu="null"
      limits_cpu="null"
    fi

    # 处理Momory数据
    a=`expr 1024 \* 1024`
    if [[ $requests_memory != "" || $limits_memory != "" ]]
    then
      requests_memory=`expr $requests_memory / $a`
      limits_memory=`expr $limits_memory / $a`
    else
      requests_memory="null"
      limits_memory="null"
    fi
    current_memory=`expr $current_memory / $a`

    # 输出数据
    echo "$rancher_env $namespace $pod $current_cpu $max_cpu $avg_cpu $requests_cpu $limits_cpu $current_memory $max_memory $avg_memory $requests_memory $limits_memory" >> .avg.txt
done
echo ""
cat .avg.txt |column -t
echo ""
rm -rf .avg.txt
}

# 4、获取 node 主机节点运行 pod 的 CPU|Memory 值
## 获取字符串所在的行数
# kubectl --context dev describe node dev-k8s-worker-server-04 |grep -n "Non-terminated Pods" |awk -F ":" '{print $1}'  ==> 57
# kubectl --context dev describe node dev-k8s-worker-server-04 |grep -n "Allocated resources" |awk -F ":" '{print $1}'  ==> 77
## 获取57-77行内容
# kubectl --context dev describe node dev-k8s-worker-server-04 |sed -n '57,77p'
## 获取所有pod的cpu、memory瞬时值
# kubectl --context dev top pod -n NAMESPACE POD_NAME

node(){
read -p "输入需要查询的环境（如:prod、dev）: " t
read -p "输入主机节点的名称（如:dev-k8s-worker-server-04）: " e
echo " "

# 定义变量
env=$t
node=$e
kube_command="kubectl --context $env describe node $node"

# 获取pod开始行、结束行
startline=`$kube_command |grep -n "Non-terminated Pods" |awk -F ":" '{print $1}'`
endline=`$kube_command |grep -n "Allocated resources" |awk -F ":" '{print $1}'`
pod_startline=$[startline+3]
pod_endline=$[endline-1]

# pod信息输出到文件中
$kube_command |sed -n ''$pod_startline','$pod_endline'p' > .pod_info
echo "Namespace Pod_Name CPU CPU_Requests CPU_Limits Memory Memory_Requests Memory_Limits Time " > .node_pod_info
echo "--------- -------- --- ------------ ---------- ------ --------------- ------------- ---- " >> .node_pod_info
echo -e "${ECHO_STYLE_04} 正在查询中...... ${ECHO_STYLE_00}"
cpu_sum=0
memory_sum=0

# 采用while重定向循环，循环体内变量可直接在体外调用
while read line
do
  pod_namespace=`echo $line |awk -F " " '{print $1}'`
  pod_name=`echo $line |awk -F " " '{print $2}'`
  CPU_Requests=`echo $line |awk -F " " '{print $3}'`
  CPU_Requests_rate=`echo $line |awk -F " " '{print $4}'`
  CPU_Limits=`echo $line |awk -F " " '{print $5}'`
  CPU_Limits_rate=`echo $line |awk -F " " '{print $6}'`
  Memory_Requests=`echo $line |awk -F " " '{print $7}'`
  Memory_Requests_rate=`echo $line |awk -F " " '{print $8}'`
  Memory_Limits=`echo $line |awk -F " " '{print $9}'`
  Memory_Limits_rate=`echo $line |awk -F " " '{print $10}'`
  Time=`echo $line |awk -F " " '{print $11}'`
  pod_cpu=`kubectl --context $env top pod -n $pod_namespace $pod_name |sed -n '2p' |awk -F " " '{print $2}'`
  pod_memory=`kubectl --context $env top pod -n $pod_namespace $pod_name |sed -n '2p' |awk -F " " '{print $3}'`
  # 输出各项指标
  echo "$pod_namespace $pod_name $pod_cpu $CPU_Requests,$CPU_Requests_rate $CPU_Limits,$CPU_Limits_rate $pod_memory $Memory_Requests,$Memory_Requests_rate $Memory_Limits,$Memory_Limits_rate $Time" >> .node_pod_info
  # 统计cpu、memory 瞬时间之和
  # 去除单位,只保留数值
  cpu_num=$(echo $pod_cpu | tr -cd '[0-9]')
  memory_num=$(echo $pod_memory | tr -cd '[0-9]')
  # 求和
  cpu_sum=`expr $cpu_sum + $cpu_num`
  memory_sum=`expr $memory_sum + $memory_num`
done < .pod_info

clear
echo "------------------------------"
echo -e "${ECHO_STYLE_04}环境:$env ${ECHO_STYLE_00}"
echo -e "${ECHO_STYLE_04}主机:$node ${ECHO_STYLE_00}"
echo "------------------------------"
# 输出pod数量
echo `$kube_command |sed -n ''$startline'p'`
# 输出pod信息
cat .node_pod_info |column -t
echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
# 输出瞬时值之和
echo -e "${ECHO_STYLE_04}CPU和内存瞬时值之和:${ECHO_STYLE_00} CPU: $cpu_sum m , Memory: $memory_sum Mi"
echo ""
# 输出pod资源统计信息
echo -e "${ECHO_STYLE_04}分配的资源占比: ${ECHO_STYLE_00}"
echo "Resource Requests Requests_Rate Limits Limits_Rate" > .allocated_resources
echo "-------- -------- ------------- ------ -----------" >> .allocated_resources
echo `$kube_command |sed -n ''$[endline+4]'p'` >> .allocated_resources
echo `$kube_command |sed -n ''$[endline+5]'p'` >> .allocated_resources
cat .allocated_resources |column -t
echo ""
# 清理临时文件
rm -rf .pod_info .node_pod_info .allocated_resources
}

# 主程序
main(){
read -p "
    1) 列出(prod|dev)环境 CPU 排行.
    2) 列出(prod|dev)环境 Memory 排行.
    3) 列出 CPU|Memory 的值(实时|最大|平均|预留|限制).
    4) 查询 node 主机节点运行 Pod 的 CPU|Memory 的值.
    0) 退出.

opt > " t

case $t in
    1)
        cpu
        ;;
    2)
        memory
        ;;
    3)
        max_avg
        ;;
    4)
        node
        ;;
    0)
        exit 1
        ;;
    *)
        echo -e "${ECHO_STYLE_03} 输入正确的序号${ECHO_STYLE_00}"
        main
        ;;
esac
}
main
