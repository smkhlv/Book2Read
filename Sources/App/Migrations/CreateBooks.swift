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
            .field("isbn", .int, .required)
            .field("title", .string, .required)
            .field("genre", .string, .required)
            .field("price", .double)
            .field("rating", .double)
            .field("publishDate", .date)
            .field("ratingCount", .int)
            .field("description", .string)
            .field("isPaperVersionAvaliable", .bool)
            .field("pageCount", .int)
            .field("isAudibleAvaliable", .bool)
            .field("backCoverText", .string)
            .field("authorName", .string)
            .field("coverImageUrl", .string)
            .field("bookData", .data)
        
        try await schema.create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Book.schema).delete()
    }
}
