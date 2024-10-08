import Fluent

struct CreateQuotes: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema(Quote.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("book_id", .uuid, .required, .references(Book.schema, "id"))
            .field("quote_text", .string, .required)
            .field("page_number", .int)
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Quote.schema).delete()
    }
}
