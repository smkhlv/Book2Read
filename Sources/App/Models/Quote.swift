import Vapor
import Fluent

final class Quote: Model, Content {
    static let schema = "quotes"

    @ID
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "book_id")
    var book: Book

    @Field(key: "quote_text")
    var quoteText: String

    @Field(key: "page_number")
    var pageNumber: Int

    init() {}

    init(id: UUID? = nil, userID: User.IDValue, bookID: Book.IDValue, quoteText: String, pageNumber: Int) {
        self.id = id
        self.$user.id = userID
        self.$book.id = bookID
        self.quoteText = quoteText
        self.pageNumber = pageNumber
    }
}

