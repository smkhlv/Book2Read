import Fluent
import Vapor

final class Review: Model, Content {
    static let schema = "reviews"
    
    @ID
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "book_id")
    var book: Book
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "rating")
    var rating: Int
    
    init() { }
    
    init(id: UUID? = nil, userId: UUID, bookId: UUID, text: String, rating: Int) {
        self.id = id
        self.$user.id = userId
        self.$book.id = bookId
        self.text = text
        self.rating = rating
    }
}
