//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation
import Crypto
import UtilCore
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequest {
    
    /// 加密的urlRequest
    /// - Returns: 返回加密后的请求
    func encrypt() throws -> URLRequest {        
        let now = Date()
        
        var publicHeaders: [String: String] = [
            "X-TC-Timestamp": "\(now.secondsTimestamp)",
            "X-TC-Language": "zh-CN",
            "Host": try requireHost()
        ]
        
        if httpMethod != "GET" {
            publicHeaders["Content-Type"] = "application/json; charset=utf-8"
        }
        
        // 合并业务header和公共header，有一些公共参数是从外部传入
        var allHeaders = publicHeaders.merging(headers, uniquingKeysWith: {_, new in new})
        let keyArray = allHeaders.keys.sorted(by: { $0 < $1 })
        
        // 签名的headerKey
        let SignedHeaders = keyArray.joined(separator: ";").lowercased()
        
        // 签名的keyValue
        let CanonicalHeaders = keyArray.map({
            "\($0.lowercased()):\((allHeaders[$0] ?? "").lowercased())\n"
        }).joined(separator: "")
        
        // body
        var HashedRequestPayload = ""
        if httpMethod != "GET", let body = httpBody {
            HashedRequestPayload = body.sha256Hash
        }
        
        guard let HTTPRequestMethod = httpMethod else {
            throw URLError(.resourceUnavailable)
        }
        
        // 组装
        let CanonicalURI = "/"
        let CanonicalQueryString = HTTPRequestMethod == "POST" ? "" : query()
        let CanonicalRequest =
"""
\(HTTPRequestMethod)
\(CanonicalURI)
\(CanonicalQueryString)
\(CanonicalHeaders)
\(SignedHeaders)
\(HashedRequestPayload)
"""
        
        let Algorithm = "TC3-HMAC-SHA256"
        let RequestTimestamp = now.secondsTimestamp
        let Service = try requireHost().split(separator: ".").first ?? "dnspod"
        let CredentialScope = "\(now.today)/\(Service)/tc3_request"
        let HashedCanonicalRequest = CanonicalRequest.sha256Hash
        let StringToSign =
"""
\(Algorithm)
\(RequestTimestamp)
\(CredentialScope)
\(HashedCanonicalRequest)
"""
        
        let SecretKey = sharedConfig.secretKey
        let SecretDate = try HMAC_SHA256(key: "TC3" + SecretKey, string: now.today)
        let SecretService = try HMAC_SHA256(hexKey: SecretDate, string: "\(Service)")
        let SecretSigning = try HMAC_SHA256(hexKey: SecretService, string: "tc3_request")
        let Signature = try HMAC_SHA256(hexKey: SecretSigning, string: StringToSign)
        
        let credential = "\(sharedConfig.secretId)/\(CredentialScope)"
        let authorization = "TC3-HMAC-SHA256 Credential=\(credential), SignedHeaders=\(SignedHeaders), Signature=\(Signature)"
        allHeaders["Authorization"] = authorization
        
        // 换成新的request
        var newRequest = self
        newRequest.allHTTPHeaderFields = allHeaders
        
        return newRequest
    }
}

public func HMAC_SHA256(key: String, string: String) throws -> String {
    return try string.hmacSha256(key: key)
}

public func HMAC_SHA256(hexKey: String, string: String) throws -> String {
    return try string.hmacSha256(hexKey: hexKey)
}

public func HMAC_SHA256(keyData: Data, string: String) throws -> String {
    return try string.hmacSha256(keyData: keyData)
}

extension URLRequest {
    
    func requireURL() throws -> URL {
        guard let url else {
            throw URLError(.badURL)
        }
        return url
    }
    
    var headers: [String: String] {
        if let allHTTPHeaderFields {
            return allHTTPHeaderFields
        }
        return [:]
    }
    
    func query() -> String {
        let query: String
#if os(Linux)
        query = url?.query ?? ""
#else
        if #available(macOS 13.0, *) {
            query = url?.query(percentEncoded: false) ?? ""
        } else {
            query = url?.query ?? ""
        }
#endif
        return query
    }
    
    func requireHost() throws -> String {
        let url = try requireURL()
        let host: String?
#if os(Linux)
        host = url.host
#else
        if #available(macOS 13.0, *) {
            host = url.host(percentEncoded: false)
        } else {
            host = url.host
        }
#endif
        guard let host else {
            throw URLError(.badURL)
        }
        return host
    }
}

public enum CryptoError: Error {
    /// key转为utf8 data失败
    case keyInvalid
    /// 加密的string转为utf8 data失败
    case stringInvalid
}

public extension Data {
    
    var sha256Hash: String {
        Data(SHA256.hash(data: self)).hex
    }
    
    func hmacSha256(key: String) throws -> String {
        if let keyData = key.data(using: .utf8) {
            return hmacSha256(keyData: keyData)
        }
        throw CryptoError.keyInvalid
    }
    
    func hmacSha256(hexKey: String) throws -> String {
        if let keyData = hexKey.hexData {
            return hmacSha256(keyData: keyData)
        }
        if let keyData = hexKey.data(using: .utf8) {
            return hmacSha256(keyData: keyData)
        }
        throw CryptoError.keyInvalid
    }
    
    func hmacSha256(keyData: Data) -> String {
        let signature = HMAC<SHA256>.authenticationCode(for: self, using: SymmetricKey(data: keyData)).hex
        return signature
    }
}

public extension String {
    var sha256Hash: String {
        if let data = data(using: .utf8) {
            return data.sha256Hash
        }
        return ""
    }
    
    func hmacSha256(hexKey: String) throws -> String {
        if let data = data(using: .utf8) {
            return try data.hmacSha256(hexKey: hexKey)
        }
        throw CryptoError.stringInvalid
    }
    
    func hmacSha256(key: String) throws -> String {
        if let data = data(using: .utf8) {
            return try data.hmacSha256(key: key)
        }
        throw CryptoError.stringInvalid
    }
    
    func hmacSha256(keyData: Data) throws -> String {
        if let data = data(using: .utf8) {
            return data.hmacSha256(keyData: keyData)
        }
        throw CryptoError.stringInvalid
    }
}
