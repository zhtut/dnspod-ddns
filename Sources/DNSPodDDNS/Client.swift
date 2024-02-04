//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation
import AsyncNetwork
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let baseURL = "https://dnspod.tencentcloudapi.com"

public struct ResponseError: Codable {
    ///       "Code": "AuthFailure.SignatureFailure",
    var Code: String
    ///       "Message": "The provided credentials could not be validated. Please check your signature is correct."
    var Message: String
}

public protocol DNSPodResponse: Codable {
    var RequestId: String { get set }
    var Error: ResponseError? { get set }
}

extension DNSPodResponse {
    var succeed: Bool {
        Error == nil
    }
}

class Client {
    
    enum ClientError: Error {
        case requestFailed
        case modelError
        case businessError(code: String, msg: String)
    }
    
    static func setup() {
        Networking.shared.baseURL = baseURL
        Networking.shared.encryptHandler = { urlRequest in
            return try urlRequest.encrypt()
        }
    }
    
    static func post<T: DNSPodResponse>(_ action: String,
                                        version: String,
                                        region: String? = nil,
                                        params: [String: Any]? = nil,
                                        dataClass: T.Type? = nil) async throws -> T {
        var headers = [
            "X-TC-Action": action,
            "X-TC-Version": version,
        ]
        if let region {
            headers["X-TC-Region"] = region
        }
        let req = Request(path: "",
                          method: .POST,
                          params: params,
                          header: headers,
                          printLog: sharedConfig.printInterfaceLog,
                          dataKey: "Response",
                          modelType: T.self)
        let res = try await Networking.shared.send(request: req)
        guard res.succeed else {
            throw ClientError.requestFailed
        }
        guard let model = res.model as? T else {
            throw ClientError.modelError
        }
        if let err = model.Error {
            throw ClientError.businessError(code: err.Code, msg: err.Message)
        }
        return model
    }
}
