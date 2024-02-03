//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation
import UtilCore
import AsyncNetwork

enum PublicIPError: Error {
    case noURL
    case fetchFailed
}

class PublicIP {
    
    var getIpv4URLConfigs = [
        [
            "url": "http://v2ray.press:5000/get_ip",
            "res": "json",
            "key": "ip"
        ],
        [
            "url": "https://www.ipuu.net/ipuu/user/getIP",
            "res": "json",
            "key": "data"
        ],
        [
            "url": "https://4.ipw.cn/api/ip/myip?json",
            "res": "json",
            "key": "IP"
        ],
        [
            "url": "https://1.1.1.1/cdn-cgi/trace",
            "res": "split",
            "key": "ip="
        ]
    ]
    
    func getIpFrom(type: SubDomainConfig.`Type`, configs: [[String: String]]) async throws -> String {
        for config in configs {
            guard let urlStr = config.stringFor("url"),
                  let key = config.stringFor("key") else {
                continue
            }
            let res = config.stringFor("res") ?? "json"
            let response = try await Networking.shared.send(request: .init(path: urlStr,
                                                                      printLog: sharedConfig.printInterfaceLog))
            if response.succeed {
                if res == "json" {
                    if let json = response.bodyJson as? [String: Any],
                       let ip = json.stringFor(key) {
                        if type == .A {
                            if ip.isValidIPv4Address {
                                return ip
                            }
                        } else {
                            if ip.isValidIPv6Address {
                                return ip
                            }
                        }
                    }
                } else {
                    if let string = response.bodyString {
                        if let str = string.split(separator: "\n").first(where: { $0.contains(key) }) {
                            let ip = "\(str)".replacingOccurrences(of: key, with: "")
                            if type == .A {
                                if ip.isValidIPv4Address {
                                    return ip
                                }
                            } else {
                                if ip.isValidIPv6Address {
                                    return ip
                                }
                            }
                        }
                    }
                }
            }
        }
        throw PublicIPError.fetchFailed
    }
    
    /// 获取公共ipv4
    /// - Returns: 返回获取到的ip
    func getPublicIpv4() async throws -> String {
        return try await getIpFrom(type: .A, configs: getIpv4URLConfigs)
    }
    
    var getIpv6URLConfigs = [
        [
            "url": "https://v6.myip.la/json",
            "res": "json",
            "key": "ip"
        ],
        [
            "url": "https://6.ipw.cn/api/ip/myip?json",
            "res": "json",
            "key": "IP"
        ],
        [
            "url": "https://[2606:4700:4700::1111]/cdn-cgi/trace",
            "res": "split",
            "key": "ip="
        ]
    ]
    
    /// 获取公共ipv4
    /// - Returns: 返回获取到的ip
    func getPublicIpv6() async throws -> String {
        return try await getIpFrom(type: .AAAA, configs: getIpv6URLConfigs)
    }
}

extension String {
    /// 判断一个string是不是一个有效的ipv4地址
    public var isValidIPv4Address: Bool {
        // 分割字符串
        let parts = self.split(separator: ".")
        
        // 检查分割后的部分数量是否为4
        guard parts.count == 4 else {
            return false
        }
        
        // 检查每个部分是否都为数字
        for part in parts {
            guard let number = Int(part) else {
                return false
            }
            
            // 检查数字是否在0-255之间
            guard (0...255).contains(number) else {
                return false
            }
        }
        
        // 返回true表示是一个有效的ipv4地址
        return true
    }
    
    /// 判断一个string是不是一个有效的ipv6地址
    public var isValidIPv6Address: Bool {
        // 分割字符串
        let parts = self.split(separator: ":")
        
        // 检查分割后的部分数量是否为8
        guard parts.count == 8 else {
            return false
        }
        
        // 检查每个部分是否都是16进制数字
        for part in parts {
            guard let number = UInt16(part, radix: 16) else {
                return false
            }
            
            // 检查数字是否在0-65535之间
            guard (0...65535).contains(number) else {
                return false
            }
        }
        
        // 返回true表示是一个有效的ipv6地址
        return true
    }
}
