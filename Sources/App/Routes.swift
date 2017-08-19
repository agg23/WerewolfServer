import Vapor

extension Droplet {
    func setupRoutes() throws {
        let gameInfoController = GameInfoController()
        get("availableCharacters", handler: gameInfoController.availableCharacters)

        let socketController = SocketController()
        socket("socket", handler: socketController.socketHandler)

        get("hello") { req in
            var json = JSON()
            json["hello"] = "world"
//            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        try resource("posts", PostController.self)
    }
}
