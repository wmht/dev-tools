#! /usr/bin
# 一周内没有更新过 tag 的 image，保留一个 tag.

CLI_HOME=/opt/data/nexus/clean-docker-images
URL="http://reg.nexus.wmq.com/v2/"

# 7*24h
INTERVAL_TIME=604800
NOW_TIME=`date +%s`

# 镜像列表
IMAGES=""
TAGS=""
IMAGES_CREATE_TIME=""

# 清理镜像
clean_images() {
  for imgs in $IMAGES;
  do
    is_unused $imgs 
    is_unused_ret=$?
    #echo "is_unused_ret: $is_unused_ret"
    if [ $is_unused_ret -eq 1 ]
    then
      delete_image $imgs
    fi
  done
}

# 获取镜像列表
get_images(){
  IMAGES=`$CLI_HOME/nexus-cli image ls|grep -v Total`

}

# 获取tag列表
get_tags(){
  imgs=$1
  TAGS=`$CLI_HOME/nexus-cli image tags -name $imgs |grep -v "^There"`
}

# 获取镜像创建时间戳
get_images_time(){
  imgs=$1
  tag=$2
  IMAGES_CREATE_TIME=`curl -sL GET $URL/$imgs/manifests/$tag |jq -r '.history[].v1Compatibility' |jq '.created' |sort |tail -n1 |xargs date +%s -d`
  #echo "获取镜像创建时间 镜像:$imgs tag: $tag  时间: $IMAGES_CREATE_TIME"
}

# 判断长时间未使用
is_unused(){
  imgs=$1
  get_tags $imgs
  for tag in $TAGS;
  do
    get_images_time $imgs $tag
    current_time_interval=`expr $NOW_TIME - $IMAGES_CREATE_TIME`
    #debug_sub=`expr $current_time_interval - $INTERVAL_TIME`
    #echo "镜像:$imgs tag: $tag  时间: $IMAGES_CREATE_TIME current_time_interval: $current_time_interval debug_sub:$debug_sub"
    if [ $current_time_interval -lt $INTERVAL_TIME ]
    then
       return 0
    fi
  done
  return 1
}

# 删除镜像
delete_image(){
  imgs=$1
  echo "清理$imgs"
  $CLI_HOME/nexus-cli image delete -name $imgs -keep 1
}

main(){
  get_images
  clean_images
}
main

