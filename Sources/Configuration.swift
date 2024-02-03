//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation

struct SubDomainConfig: Codable {
    /// 记录类型
    enum `Type`: String, Codable {
        /// ipv4
        case A
        /// ipv6
        case AAAA
    }
    /// ip类型
    var type: `Type`
    /// 子域名名称，不填写则为@
    var name: String?
    /// ttl时长，默认为10分钟，600s
    var ttl: Int = 600
    /// 备注
    var desc: String?
}

struct DomainConfig: Codable {
    var domain: String
    var subDomains: [SubDomainConfig]
}

struct Configuration: Codable {
    var secretId: String
    var secretKey: String
    var domainConfigs: [DomainConfig]
    /// 多少秒开始检查一次
    var timeInverval: TimeInterval
    /// 打印接口日志，默认为no
    var printInterfaceLog: Bool = false
}

var sharedConfig: Configuration!

func loadConfig() throws {
    var configPath = "/config.json"
#if os(macOS)
    let home = NSHomeDirectory()
    configPath = home + "/Desktop/thirds/dnspod_ddns/config.json"
#endif
    let url: URL
#if os(Linux)
    url = URL(fileURLWithPath: configPath)
#else
    if #available(macOS 13.0, *) {
        url = URL(filePath: configPath)
    } else {
        url = URL(fileURLWithPath: configPath)
    }
#endif
    let data = try Data(contentsOf: url)
    let model = try JSONDecoder().decode(Configuration.self, from: data)
    sharedConfig = model
}
