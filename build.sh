app_name="dnspod-ddns"
docker build --platform linux/amd64 -t shutut/$app_name:amd64 --push .
docker build --platform linux/arm64/v8 -t shutut/$app_name:arm64 --push .
