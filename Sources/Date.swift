//
//  File.swift
//  
//
//  Created by tutuzhou on 2024/2/3.
//

import Foundation

public extension Date {
    /// 获取今天的日期
    var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
    
    /// 获取现在的描述
    var desc: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    /// 今天的时间戳，单位：秒
    var secondsTimestamp: Int {
        return Int(timeIntervalSince1970)
    }
    
    /// 今天的时间戳，单位：毫秒
    var millsecondsTimestamp: Int {
        return Int(timeIntervalSince1970 * 1000.0)
    }
}
