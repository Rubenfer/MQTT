import Vapor
import MQTTNIO
import NIO

public class MQTTContainers {
    public struct ID: Hashable, Codable {
        public let string: String
        public init(string: String) {
            self.string = string
        }
    }

    public final class Container {
        public let configuration: MQTTClient.Configuration
        public let client: MQTTClient
        
         internal init(configuration: MQTTClient.Configuration, client: MQTTClient) {
            self.configuration = configuration
            self.client = client
        }
    }

    private var containers: [ID: Container]
    private var defaultID: ID?
    private var lock: Lock

    init() {
        self.containers = [:]
        self.lock = .init()
    }

    public func syncShutdown() {
        self.lock.lock()
        defer { self.lock.unlock() }
        do {
            try containers.forEach { key, container in
                try container.client.syncShutdownGracefully()
            }
        } catch {
            fatalError("Could not shutdown MQTT Containers")
        }
    }
}

extension MQTTContainers {

    public func use(
        _ config: MQTTClient.Configuration,
        host: String,
        port: Int = 1883,
        identifier: String,
        eventLoopGroupProvider: NIOEventLoopGroupProvider,
        backgroundActivityLogger: Logger,
        as id: ID,
        isDefault: Bool? = nil
    ) {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.containers[id] = Container(
            configuration: config,
            client: MQTTClient(host: host,
                               port: port,
                               identifier: identifier,
                               eventLoopGroupProvider: eventLoopGroupProvider,
                               logger: backgroundActivityLogger,
                               configuration: config)
        )

        if isDefault == true || (self.defaultID == nil && isDefault != false) {
            self.defaultID = id
        }
    }

    public func `default`(to id: ID) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.defaultID = id
    }

    public func container(for id: ID? = nil) -> MQTTContainers.Container? {
        self.lock.lock()
        defer { self.lock.unlock() }
        guard let id = id ?? self.defaultID else {
            return nil
        }
        return self.containers[id]
    }

    public var container: MQTTContainers.Container? {
        container()
    }
}
