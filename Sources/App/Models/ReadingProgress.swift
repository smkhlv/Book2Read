import Fluent
import Vapor

final class ReadingProgress: Model, Content {
    static let schema = "reading_progress"

    @ID
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "book_id")
    var book: Book

    @Field(key: "current_page")
    var currentPage: Int

    @Field(key: "last_update")
    var lastUpdate: Date

    init() {}

    init(id: UUID? = nil, userID: User.IDValue, bookID: Book.IDValue, currentPage: Int, lastUpdate: Date) {
        self.id = id
        self.$user.id = userID
        self.$book.id = bookID
        self.currentPage = currentPage
        self.lastUpdate = lastUpdate
    }
}

