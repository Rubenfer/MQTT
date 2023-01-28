import MQTTNIO
import Vapor
import NIOConcurrencyHelpers

extension Application {
    public var mqtt: MQTT {
        return .init(application: self)
    }

    public struct MQTT {

        // Synchronize access across threads.
        private var lock: NIOLock

        struct ContainersKey: StorageKey, LockKey {
            typealias Value = MQTTContainers
        }

        public var containers: MQTTContainers {
            if let existingContainers = self.application.storage[ContainersKey.self] {
                return existingContainers
            } else {
                let lock = self.application.locks.lock(for: ContainersKey.self)
                lock.lock()
                defer { lock.unlock() }
                let new = MQTTContainers()
                self.application.storage.set(ContainersKey.self, to: new) {
                    $0.syncShutdown()
                }
                return new
            }
        }

        public var client: MQTTClient {
            guard let container = containers.container() else {
                fatalError("No default MQTT container configured.")
            }
            return container.client
        }

        public func client(_ id: MQTTContainers.ID = .default) -> MQTTClient {
            guard let container = containers.container(for: id) else {
                fatalError("No MQTT container for \(id).")
            }
            return container.client
        }

        let application: Application

        public init(application: Application) {
            self.application = application
            self.lock = .init()
        }
    }
}
