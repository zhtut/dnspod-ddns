//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation

class CheckTask {
    
    var isNeedIpv4 = false
    var isNeedIpv6 = false
    
    func processIp(type: SubDomainConfig.`Type`) async throws {
        let nowIp: String
        do {
            if type == .A {
                nowIp = try await PublicIP().getPublicIpv4()
            } else {
                nowIp = try await PublicIP().getPublicIpv6()
            }
            print("获取到ip地址：\(nowIp)")
        } catch {
            print("获取ip失败：\(error)")
            return
        }
        for config in sharedConfig.domainConfigs {
            for subdomin in config.subDomains.filter({ $0.type == type }) {
                do {
                    let records = try await RecordManager.getRecords(config.domain, type: type, config: subdomin)
                    let selfRecords = records.filter({ $0.Name == subdomin.name && $0.Type == subdomin.type.rawValue })
                    // 找出匹配当前域名的记录
                    if selfRecords.count == 1 && selfRecords.first?.Value == nowIp {
                        // 如果只是唯一的一个值，则使用他
                        print("\(config.domain)域名的子域名\(subdomin.name ?? "@")已包含IP:\(nowIp)")
                        continue
                    } else {
                        // 否则删除所有这个子域名的值，下面会重新设置这个记录的值
                        for del in selfRecords {
                            print("\(config.domain)域名的子域名\(subdomin.name ?? "@")当前IP:\(del.Value)与现有的ip不同：\(nowIp)，需要先删除这条记录")
                            do {
                                try await RecordManager.deleteRecord(config.domain, recordId: del.RecordId)
                            } catch {
                                print("删除ip错误：\(error)")
                            }
                        }
                    }
                } catch {
                    print("查询ip错误：\(error)")
                }
                do {
                    try await RecordManager.setRecord(config.domain, type: type, config: subdomin, ip: nowIp)
                    print("\(config.domain)域名的子域名\(subdomin.name ?? "@")添加记录成功：\(nowIp)")
                } catch {
                    print("\(config.domain)域名的子域名\(subdomin.name ?? "@")添加记录失败：\(error)")
                }
            }
        }
    }
    
    func run(index: Int) async throws {
        print("----\n开始执行第\(index)次任务，现在时间: \(Date().desc)----")
        
        sharedConfig.domainConfigs
            .forEach { domainConfig in
                isNeedIpv4 = (domainConfig.subDomains.first(where: { $0.type == .A }) != nil)
                isNeedIpv6 = (domainConfig.subDomains.first(where: { $0.type == .AAAA }) != nil)
            }
        
        if isNeedIpv4 {
            print("需要获取ipv4的ip")
            try await processIp(type: .A)
        }
        
        if isNeedIpv6 {
            print("需要获取ipv6的ip")
            try await processIp(type: .AAAA)
        }
        
        print("完成第\(index)次任务")
    }
}
