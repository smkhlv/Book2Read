//
//  CreateNews.swift
//
//
//  Created by Igoryok on 22.02.2024.
//

import Fluent

struct CreateNews: AsyncMigration {
    func prepare(on database: Database) async throws {
        let schema = database.schema(News.schema)
            .id()
            .field("title", .string, .required)
            .field("imageUrl", .string, .required)
            .field("language", .string, .required)

        try await schema.create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Book.schema).delete()
    }
}
