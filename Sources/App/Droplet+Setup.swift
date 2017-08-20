@_exported import Vapor

extension Droplet {
    public func setup() throws {
        Logger.droplet = self
        WebController.instance.registerRoutes(to: self)
    }
}
