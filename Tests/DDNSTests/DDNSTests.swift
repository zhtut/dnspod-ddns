@testable import DNSPodDDNS
import XCTest

final class AppTests: XCTestCase {
    func testHelloWorld() async throws {
        print("开始我的打印")
    }
}

/*
 docker run -it -v "$(pwd)/:/src" -w "/src/" --name 'debug' swift:jammy
  */
