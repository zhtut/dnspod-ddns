// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Dispatch

print("开始读取配置")

try loadConfig()

print("初始化网络引擎")

Client.setup()

var index = 1
func run() {
    Task {
        do {
            try await CheckTask().run(index: index)
        } catch {
            print("第\(index)次检查失败：\(error)")
        }
        index += 1
        DispatchQueue.global().asyncAfter(deadline: .now() + sharedConfig.timeInverval) {
            run()
        }
    }
}

run()

RunLoop.current.run()
