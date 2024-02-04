//
//  CreateBooks.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Fluent

struct CreateBooks: AsyncMigration {
    func prepare(on database: Database) async throws {
        let schema = database.schema(Book.schema)
            .id()
            .field("isbn", .string, .required)
            .field("title", .string, .required)
            .field("genre", .string, .required)
            .field("price", .double, .required)
            .field("rating", .double, .required)
            .field("publishDate", .date, .required)
            .field("ratingCount", .int, .required)
            .field("description", .string, .required)
            .field("isPaperVersionAvailable", .bool, .required)
            .field("pageCount", .int, .required)
            .field("isAudibleAvailable", .bool, .required)
            .field("backCoverText", .string, .required)
            .field("coverImageUrl", .string, .required)
            .field("authorId", .uuid, .required)
            .field("fileUrl", .string, .required)
            .field("audio_book", .uuid, .required, .references("audiobooks", "id"))
            .field("language", .string, .required)

        try await schema.create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Book.schema).delete()
    }
}
