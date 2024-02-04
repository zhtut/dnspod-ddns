app_name="dnspod_ddns"
docker buildx build --platform linux/amd64,linux/arm64/v8 -t shutut/$app_name --push .