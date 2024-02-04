//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation

public struct Record: Codable {
    ///    "RecordId": 556507778,
    public var RecordId: Int
    ///    "Value": "f1g1ns1.dnspod.net.",
    public var Value: String
    ///    "Status": "ENABLE",
    public var Status: String
    ///    "UpdatedOn": "2021-03-28 11:27:09",
    public var UpdatedOn: String
    ///    "Name": "@",
    public var Name: String
    ///    "Line": "默认",
    public var Line: String
    ///    "LineId": "0",
    public var LineId: String
    ///    "Type": "NS",
    public var `Type`: String
    ///    "Weight": null,
    public var Weight: String?
    ///    "MonitorStatus": "",
    public var MonitorStatus: String
    ///    "Remark": "",
    public var Remark: String
    ///    "TTL": 86400,
    public var TTL: Int
    ///    "MX": 0,
    public var MX: Int
}

public struct RecordCountInfo: Codable {
    ///    "SubdomainCount": 2,
    public var SubdomainCount: Int
    ///    "TotalCount": 2,
    public var TotalCount: Int
    ///    "ListCount": 2
    public var ListCount: Int
}

public struct GetRecordListResponse: DNSPodResponse, Codable {
    public var RequestId: String
    public var Error: ResponseError?
    public var RecordList: [Record]
    public var RecordCountInfo: RecordCountInfo
}

public struct SetRecordResponse: DNSPodResponse, Codable {
    public var RequestId: String
    
    public var Error: ResponseError?
    
    public var RecordId: Int?
}

enum RecordError: Error {
    case notFoundRecord(_ params: [String: String])
}

class RecordManager {
    /// 获取某个域名的子域名的ip
    static func getRecord(_ domain: String, type: SubDomainConfig.`Type`, config: SubDomainConfig) async throws -> Record {
        let params = [
            "Domain": domain,
            "Subdomain": config.name ?? "@",
            "RecordType": type.rawValue
        ]
        let res = try await Client.post("DescribeRecordList",
                                     version: "2021-03-23",
                                     params: params,
                                     dataClass: GetRecordListResponse.self)
        if let first = res.RecordList.first {
            return first
        }
        throw RecordError.notFoundRecord(params)
    }
    
    /// 设置一条记录
    static func setRecord(_ domain: String, type: SubDomainConfig.`Type`, config: SubDomainConfig, ip: String) async throws {
        var params = [
            "Domain": domain,
            "SubDomain": config.name ?? "@",
            "RecordType": type.rawValue,
            "RecordLine": "默认",
            "Value": ip,
            "TTL": config.ttl,
        ] as [String: Any]
        
        if let desc = config.desc {
            params["Remark"] = desc
        }
        _ = try await Client.post("CreateRecord",
                                  version: "2021-03-23",
                                  params: params,
                                  dataClass: SetRecordResponse.self)
    }
    
    /// 删除一条记录
    static func deleteRecord(_ domain: String, recordId: Int) async throws {
        let params = [
            "Domain": domain,
            "RecordId": recordId
        ] as [String: Any]
        _ = try await Client.post("DeleteRecord",
                                  version: "2021-03-23",
                                  params: params,
                                  dataClass: SetRecordResponse.self)
    }
}
