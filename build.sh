
app_name="dnspod-ddns"
docker_build_command="docker buildx build --no-cache --platform linux/amd64,linux/arm64/v8"
eval $docker_build_command -t shutut/$app_name --push .