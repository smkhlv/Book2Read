//
//  User.swift
//
//
//  Created by Sergei on 22.1.24..
//

import Fluent
import Vapor

final class User: Model {
    struct Public: Content {
        let id: UUID
        let username: String
        let createdAt: Date?
        let updatedAt: Date?
        let boughtBooksIds: [UUID]
        let language: String
    }

    static let schema = "users"

    @ID
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Field(key: "bought_book_ids")
    var boughtBooksIds: [UUID]

    @Field(key: "language")
    var language: String

    init() {}

    init(id: UUID? = nil,
         username: String,
         passwordHash: String,
         boughtBooksIds: [UUID] = [],
         language: String)
    {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.boughtBooksIds = boughtBooksIds
        self.language = language
    }
}

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        try User(username: userSignup.username,
                 passwordHash: Bcrypt.hash(userSignup.password),
                 language: userSignup.language)
    }

    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(userId: requireID(),
                         token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }

    func asPublic() throws -> Public {
        try Public(id: requireID(),
                   username: username,
                   createdAt: createdAt,
                   updatedAt: updatedAt,
                   boughtBooksIds: boughtBooksIds,
                   language: language)
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
}
