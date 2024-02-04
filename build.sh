app_name="dnspod_ddns"
arch=$(uname -m)
name=shutut
docker build -t $name/$app_name:$arch --push .
# swift还不支持跨平台构建，在mac m1上运行amd64的镜像，swift的命令都报错了，
# 所以这里需要分开构建，然后再通过manifest合到一起
docker manifest create \
$name/$app_name:latest \
--amend $name/$app_name:amd64 \
--amend $name/$app_name:arm64