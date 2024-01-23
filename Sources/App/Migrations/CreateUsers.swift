//
//  CreateUsers.swift
//
//
//  Created by Sergei on 22.1.24..
//

import Fluent

struct CreateUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        let schema = database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password_hash", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
        
        try await schema.create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
