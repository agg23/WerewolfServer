@_exported import Vapor

extension Droplet {
    public func setup() throws {
        WebController.instance.registerRoutes(to: self)
    }
}
