import Fluent
import Vapor

final class Review: Model, Content {
    static let schema = "reviews"

    @ID
    var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @Field(key: "book_id")
    var bookId: UUID

    @Field(key: "text")
    var text: String

    @Field(key: "rating")
    var rating: Int

    init() {}

    init(id: UUID? = nil, userId: UUID, bookId: UUID, text: String, rating: Int) {
        self.id = id
        self.userId = userId
        self.bookId = bookId
        self.text = text
        self.rating = rating
    }
}
