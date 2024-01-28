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
//            .field("price", .double, .required)
//            .field("progress", .double)
//            .field("rating", .double)
//            .field("publishDate", .date, .required)
//            .field("ratingCount", .int, .required)
//            .field("description", .string, .required)
//            .field("isPaperVersionAvaliable", .bool, .required)
//            .field("pageCount", .int, .required)
//            .field("isAudibleAvaliable", .bool, .required)
//            .field("backCoverText", .string, .required)
//            .field("authorName", .string, .required)
//            .field("coverImageUrl", .string, .required)
        
        try await schema.create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Book.schema).delete()
    }
}
