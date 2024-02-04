import Fluent

struct CreateAudioBooks: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let schema = database.schema(AudioBook.schema)
            .id()
            .field("price", .double, .required)
            .field("rating", .double, .required)
            .field("ratingCount", .int, .required)
            .field("fileUrl", .string, .required)
            .field("book_id", .uuid, .required, .references("books", "id"))
        
        try await schema.create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(AudioBook.schema).delete()
    }
}
