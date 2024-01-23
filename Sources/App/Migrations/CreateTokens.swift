//
//  CreateTokens.swift
//
//
//  Created by Sergei on 23.1.24..
//

import Fluent

struct CreateTokens: AsyncMigration {
    func prepare(on database: Database) async throws {
        let schema = database.schema(Token.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("user_id", .uuid, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("source", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime)
        
        try await schema.create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema).delete()
    }
}
