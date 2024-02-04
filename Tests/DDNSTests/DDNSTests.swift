@testable import DNSPodDDNS
import XCTest

final class AppTests: XCTestCase {
    func testHelloWorld() async throws {
        print("开始我的打印")
    }
}

/*
 docker run \
 --rm -it \
 --volume "$(pwd)/:/src" \
 --workdir "/src/" \
 --platform linux/amd64 \
 swift:jammy
  */
