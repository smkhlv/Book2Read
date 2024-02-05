//
//  AddAudioBookReference.swift
//
//
//  Created by Igoryok on 05.02.2024.
//

import Fluent

struct AddAudioBookReference: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Book.schema)
            .field("audio_book", .uuid, .required)
            .foreignKey("audio_book", references: AudioBook.schema, "id", onDelete: .cascade)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Book.schema)
            .deleteField("audio_book")
            .update()
    }
}
