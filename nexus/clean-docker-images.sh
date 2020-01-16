#! /bin/sh
# 清理镜像,每个镜像只保留最新10个tag
CLI_HOME=/opt/data/nexus/clean-docker-images
KEEP_VERSION_NUM=10
cd $CLI_HOME

IMAGES=$($CLI_HOME/nexus-cli image ls|grep -v Total)

clean_images() {
  for imgs in $(echo $IMAGES);
  do
    echo "清理$imgs";
    $CLI_HOME/nexus-cli image delete -name $imgs -keep $KEEP_VERSION_NUM
  done
}
clean_images
