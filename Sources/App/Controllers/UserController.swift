//
//  UserController.swift
//
//
//  Created by Sergei on 22.1.24..
//

import Fluent
import Vapor

struct UserSignup: Content {
    let username: String
    let password: String
    let language: String
}

struct NewSession: Content {
    let token: String
    let user: User.Public
}

extension UserSignup: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: create)

        let tokenProtected = usersRoute.grouped(Token.authenticator())
        tokenProtected.get("me", use: getMyOwnUser)
        tokenProtected.delete("delete", use: deleteUser)
        tokenProtected.post("logout", use: logout)
        tokenProtected.post(":bookId", "buy", use: buyBook)
        tokenProtected.post("setLanguage", use: setLanguage)
        tokenProtected.post(":userId", use: getUser)

        let passwordProtected = usersRoute.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
    }

    private func create(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)
        var token: Token!

        return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: UserError.usernameTaken)
            }

            return user.save(on: req.db)
        }.flatMap {
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            try NewSession(token: token.value, user: user.asPublic())
        }
    }

    private func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)

        return token.save(on: req.db).flatMapThrowing {
            try NewSession(token: token.value, user: user.asPublic())
        }
    }

    private func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)

        return Token.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .delete()
            .flatMap {
                user.delete(on: req.db)
            }
            .transform(to: .ok)
    }

    private func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let token = req.auth.get(Token.self) else {
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }

        return token.delete(on: req.db).transform(to: .ok)
    }

    private func getMyOwnUser(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }

    private func buyBook(req: Request) async throws -> HTTPStatus {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        let user = try req.auth.require(User.self)

        guard !user.boughtBooksIds.contains(bookId) else {
            throw Abort(.badRequest, reason: "Book is already bought")
        }

        user.boughtBooksIds.append(bookId)

        try await user.save(on: req.db)

        return .ok
    }

    func setLanguage(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let newLanguage = try req.content.decode(String.self)

        user.language = newLanguage

        try await user.save(on: req.db)

        return .ok
    }

    private func getUser(req: Request) async throws -> User.Public {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User \(userId) is not found")
        }

        return try user.asPublic()
    }

    private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$username == username)
            .first()
            .map { $0 != nil }
    }
}
