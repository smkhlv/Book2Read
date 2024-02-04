import Fluent

struct CreateReadingProgress: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema(ReadingProgress.schema)
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("book_id", .uuid, .required, .references("books", "id"))
            .field("current_page", .int, .required)
            .field("last_update", .datetime, .required)

        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(ReadingProgress.schema).delete()
    }
}
