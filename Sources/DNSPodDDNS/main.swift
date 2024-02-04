// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

print("开始读取配置")

try loadConfig()

print("初始化网络引擎")

Client.setup()

var index = 1
func run() {
    Task {
        try await CheckTask().run(index: index)
        index += 1
    }
}

run()

let timer = Timer.scheduledTimer(withTimeInterval: sharedConfig.timeInverval, repeats: true) { timer in
    run()
}
RunLoop.current.add(timer, forMode: .common)
RunLoop.current.run()
