//
//  CreateAuthors.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Fluent

struct CreateAuthors: AsyncMigration {
    func prepare(on database: Database) async throws {
        let database = database.schema(Author.schema)
            .id()
            .field("name", .string, .required)

        try await database.create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Author.schema).delete()
    }
}
