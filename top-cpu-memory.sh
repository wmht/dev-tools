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

# 生产环境CPU
prod_cpu(){
kubectl --context prod top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .prod_top.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 生产环境, Pod 占用 CPU 排行                                                  ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .prod_top.txt |sort -k 3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 生产环境, 各项目的 Pod 占用 CPU 排行                                            ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .prod_top.txt |sort -k1,1 -k3,3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 生产环境，各项目占用 CPU 排行               ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加，
cat .prod_top.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 2nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .prod_top.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .prod_top.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
}

# 生产环境内存
prod_memory(){
kubectl --context prod top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .prod_memory.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 生产环境 Memory 排行                                                           ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .prod_top.txt |sort -k 4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 生产环境, 各项目的 Pod 占用 Memory 排行                                          ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .prod_top.txt |sort -k1,1 -k4,4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 生产环境，各项目占用 Memory 排行              ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加
cat .prod_top.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 3nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .prod_top.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .prod_top.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
}

# 测试环境CPU
dev_cpu(){
kubectl --context dev top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .dev_top.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 测试环境 CPU 排行                                                           ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .dev_top.txt |sort -k 3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 测试环境, 各项目的 Pod 占用 CPU 排行                                          ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .dev_top.txt |sort -k1,1 -k3,3nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 测试环境，各项目占用 CPU 排行               ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加，
cat .dev_top.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 2nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .dev_top.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .dev_top.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
}

# 测试环境内存
dev_memory(){
kubectl --context dev top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .dev_memory.txt
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 测试环境 Memory 排行                                                        ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .dev_top.txt |sort -k 4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 测试环境, 各项目的 Pod 占用 Memory 排行                                          ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .dev_top.txt |sort -k1,1 -k4,4nr
echo "-------------------------------------------------------------------------------------------------------------"

echo -e "${ECHO_STYLE_02} 测试环境，各项目占用 Memory 排行                     ${ECHO_STYLE_00}"
# namespace 相同，cpu相加，memory相加
cat .dev_top.txt |awk '{ a[$1]+=$3; b[$1]+=$4 }END{ for(i in a) print i,a[i],b[i]}' |sort -k 3nr |column -t

echo "-------------------------------------------------------------------------------------------------------------"
cpu_total=`cat .dev_top.txt |awk '{sum += $3};END {print sum}'`
memory_total=`cat .dev_top.txt |awk '{sum += $4};END {print sum}'`
echo -e "${ECHO_STYLE_04} 占用资源总计 | CPU: $cpu_total m , Memory: $memory_total Mi   ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
echo ""
}


prod_limits_cpu_memory(){
kubectl --context prod top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .prod_top.txt
echo > .prod_limits.txt
cat .prod_top.txt |while read line
do
    RANCHER_ENV="prod"
    NAMESPACE=`echo "${line}" |awk '{print $1}'`
    POD=`echo "${line}" |awk '{print $2}'`
    used_cpu=`echo "${line}" |awk '{print $3}'`
    used_memory=`echo "${line}" |awk '{print $4}'`
    requests_cpu=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.requests.cpu}'`
    limits_cpu=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.limits.cpu}'`
    requests_memory=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.requests.memory}'`
    limits_memory=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.limits.memory}'`
    echo "环境:$RANCHER_ENV  命名空间:$NAMESPACE  POD名称:$POD  使用CPU:$used_cpu  预留CPU:$requests_cpu  限制CPU:$limits_cpu  使用内存:$used_memory  预留内存:$requests_memory  限制内存:$limits_memory" >> .prod_limits.txt
done
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 生产环境 CPU 和 Memory 的使用值、预留值、限制值                                                 ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .prod_limits.txt |column -t
echo ""
}


dev_limits_cpu_memory(){
kubectl --context dev top pod --all-namespaces|grep -v "^cattle"|grep -v "^ingress"|grep -v "^kube-system"|grep -v "^istio-system"|grep -v "^NAMESPACE" > .dev_top.txt
echo > .dev_limits.txt
cat .dev_top.txt |while read line
do
    RANCHER_ENV="dev"
    NAMESPACE=`echo "${line}" |awk '{print $1}'`
    POD=`echo "${line}" |awk '{print $2}'`
    used_cpu=`echo "${line}" |awk '{print $3}'`
    used_memory=`echo "${line}" |awk '{print $4}'`
    requests_cpu=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.requests.cpu}'`
    limits_cpu=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.limits.cpu}'`
    requests_memory=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.requests.memory}'`
    limits_memory=`kubectl --context $RANCHER_ENV -n $NAMESPACE get pods $POD -o=jsonpath='{.spec.containers[0].resources.limits.memory}'`
    echo "环境:$RANCHER_ENV  命名空间:$NAMESPACE  POD名称:$POD  使用CPU:$used_cpu  预留CPU:$requests_cpu  限制CPU:$limits_cpu  使用内存:$used_memory  预留内存:$requests_memory  限制内存:$limits_memory" >> .dev_limits.txt
done
echo "-------------------------------------------------------------------------------------------------------------"
echo -e "${ECHO_STYLE_02} 测试环境 CPU 和 Memory 的使用值、预留值、限制值                                                 ${ECHO_STYLE_00}"
echo "-------------------------------------------------------------------------------------------------------------"
cat .dev_limits.txt |column -t
echo ""
}


# 主程序
main(){
read -p "
    1) 列出所有生产环境 CPU 排行.
    2) 列出所有生产环境 Memory 排行.
    3) 列出所有测试环境 CPU 排行.
    4) 列出所有测试环境 Memory 排行.
    5) 列出所有生产环境 CPU 和 Memory 的使用值、预留值、限制值.
    6) 列出所有测试环境 CPU 和 Memory 的使用值、预留值、限制值.
    0) 退出.

opt > " t

case $t in
    1)
        prod_cpu
        ;;
    2)
        prod_memory
        ;;
    3)
        dev_cpu
        ;;
    4)
        dev_memory
        ;;
    5)
        echo ""
        echo "正在查询中...."
        prod_limits_cpu_memory
        ;;
    6)
        echo ""
        echo "正在查询中...."
        dev_limits_cpu_memory
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
