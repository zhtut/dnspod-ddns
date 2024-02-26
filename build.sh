app_name="dnspod_ddns"
arch=$(uname -m)
if [ $arch == 'x86_64' ]; then
  arch="amd64"
fi
name=shutut
docker build -t $name/$app_name:$arch --push .
# swift还不支持跨平台构建，在mac m1上运行amd64的镜像，swift的命令都报错了，
# 所以这里需要分开构建，然后再通过manifest合到一起
#docker manifest create \
#$name/$app_name:latest \
#-a $name/$app_name:amd64 \
#-a $name/$app_name:arm64
#docker manifest push $name/$app_name:latest

#  docker run -it -v "$(pwd)/:/src" -w "/src/" --name 'debug' swift:jammy
