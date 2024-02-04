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
        try await CheckTask().run(index: index)
        index += 1
        DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
            run()
        }
    }
}

run()

RunLoop.current.run(mode: .default, before: Date.distantFuture)
