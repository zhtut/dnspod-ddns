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
                    let record = try await RecordManager.getRecord(config.domain, type: type, config: subdomin)
                    if record.Value == nowIp {
                        print("\(config.domain)域名的子域名\(subdomin.name ?? "@")已包含IP:\(nowIp)")
                        continue
                    } else {
                        print("\(config.domain)域名的子域名\(subdomin.name ?? "@")当前IP:\(record.Value)与现有的ip不同：\(nowIp)，需要先删除这条记录")
                        do {
                            try await RecordManager.deleteRecord(config.domain, recordId: record.RecordId)
                        } catch {
                            print("删除ip错误：\(error)")
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
