import XCTest
import XCTVapor
@testable import MQTT

final class MQTTTests: XCTestCase {
    
    func testApplication() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        app.mqtt.containers.use(.init(),
                                host: "test.mosquitto.org",
                                identifier: "MQTT-for-Vapor",
                                eventLoopGroupProvider: .shared(app.eventLoopGroup),
                                backgroundActivityLogger: app.logger,
                                as: .default)
        
        try await app.mqtt.client.connect()
        
        app.get("test-mqtt") { req -> HTTPStatus in
            try await app.mqtt.client.publish(to: "test/mqtt-for-vapor",
                                              payload: ByteBuffer(string: "This is a test from MQTT for Vapor"),
                                              qos: .atMostOnce)
            return .ok
        }
        
        try app.test(.GET, "test-mqtt") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
}
