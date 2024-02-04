#!/bin/sh

app_name="dnspod-ddns"

# 这里使用一个中转容器，用于存放代码，每次编译的时候，把新的代码拷进去，
# 然后再执行构建，可以免去很多编译的时间，然后再把东西拷出来进行安装
cache_image="$app_name-cache"

build_new="Dockerfile-build-new"
build_cache="Dockerfile-build-cache"
cp_run="Dockerfile-cp-run"

docker_build_command="docker buildx build --no-cache --platform linux/arm/v8"

#docker pull swift:jammy
#docker pull swift:jammy-slim

if [[ $(docker image ls) =~ $cache_image ]]; then
  echo "已有Cache镜像，使用Cache镜像开始build"
  $docker_build_command -f $build_cache -t $cache_image --load .
  if [[ $? != 0 ]]; then
    echo "编译失败"
    exit 1
  fi
  echo "编译成功，开始部署"
else
  echo "还没有Cache镜像，先编译Cache镜像"
  $docker_build_command -f $build_new -t $cache_image --load .
  if [[ $? != 0 ]]; then
    echo "编译Cache失败"
    exit 1
  fi
  echo "编译Cache镜像完成，开始部署"
fi

$docker_build_command -f $cp_run -t shutut/$app_name --push .
if [[ $? != 0 ]]; then
  echo "编译server失败"
  exit 1
fi

echo "部署成镜像成功，开始启动"
docker compose up -d --force-recreate
if [[ $? != 0 ]]; then
  echo "启动失败"
  exit 1
fi

echo "清除不需要的镜像"
docker image prune -f

echo "完成"
