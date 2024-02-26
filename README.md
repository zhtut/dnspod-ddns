# dnspod ddns 功能
用swift来实现

# 使用
## 配置config.json
// 注释需要删除
```
{
  "domainConfigs": [
    {
      "domain": "baidu.com",
      "subDomains": [
        {
          "name": "@",
          "type": "A",
          "ttl": 600,
          "desc": ""
        }
      ]
    }
  ],
  "timeInverval": 60,
  "secretKey": "",
  "secretId": "",
  "printInterfaceLog": false,
  "wrongIpv4s": []
}
```

|  字段   | 含义  |
|  ----  | ----  |
| domain | 主域名 |
| subDomains  | 子域名配置 |
| -name  | 子域名名称，@代表隐藏，这里可以填www或者其他的 |
| -type  | ip类型，A代表ipv4，4A代表ipv6，只支持这两种 |
| -ttl  | ttl时间，单位为秒，dnspod免费版最小只支持600， |
| -desc  | 备注，不填写就默认空就行了 |
| timeInverval  | 检查更新的时间，单位为秒 |
| secretKey  | 腾讯云api密钥,[在这申请](https://console.dnspod.cn/account/token/apikey)，不是dnsPodToken, dnsPodToken那套接口后续会下架 |
| secretId  | 腾讯云api密钥Id,[在这申请](https://console.dnspod.cn/account/token/apikey)，不是dnsPodToken, dnsPodToken那套接口后续会下架 |
| printInterfaceLog  | 是否打印接口日志 |
| wrongIpv4s  | 获取到的错误的ipv4地址，常见于使用了代理，然后获取到了代理的ip，这里可以去除，会尝试使用别的地址去获取正确的ip |
## 配置docker-compose.yml
```
version: '3.9'

services:
  ddns:
    image: shutut/dnspod_ddns
    restart: always
    container_name: ddns
    tty: true
    volumes:
# 这个./config.json需要指向你配置的config.json目录
      - ./config.json:/config.json
```
## 启动 docker compose up -d
关闭 docker compose down
