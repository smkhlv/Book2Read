//
//  AuthorController.swift
//  
//
//  Created by Sergei on 25.1.24..
//

import Vapor
import Fluent

struct AuthorController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let authorsRoute = routes.grouped("authors")
        let tokenProtected = authorsRoute.grouped(Token.authenticator())
        
        tokenProtected.post("create", use: create)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Author> {
        let authorData = try req.content.decode(Author.self)
        return authorData.save(on: req.db).map { authorData }
    }
}
