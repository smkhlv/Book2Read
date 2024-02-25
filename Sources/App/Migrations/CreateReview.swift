import Fluent

struct CreateReview: AsyncMigration {
    func prepare(on database: Database) async throws {
        let schema = database.schema("reviews")
            .id()
            .field("user_id", .uuid, .required)
            .field("book_id", .uuid, .required)
            .field("text", .string, .required)
            .field("rating", .int, .required)

        try await schema.create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("reviews").delete()
    }
}
