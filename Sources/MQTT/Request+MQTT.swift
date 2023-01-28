import MQTTNIO
import Vapor

extension Request {
    public var mqtt: Application.MQTT {
        .init(application: self.application)
    }
}
