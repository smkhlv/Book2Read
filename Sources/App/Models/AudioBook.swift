import Fluent
import Vapor

final class AudioBook: Model, Content {
    static let schema = "audiobooks"
    
    @ID
    var id: UUID?
    
    @Field(key: "price")
    var price: Double
    
    @Parent(key: "book_id")
    var book: Book
    
    @Field(key: "rating")
    var rating: Double
    
    @Field(key: "ratingCount")
    var ratingCount: Int
    
    @Field(key: "fileUrl")
    var fileUrl: String
    
    init() { }
    
    convenience init(id: UUID? = nil, price: String, book: Book, rating: String, ratingCount: String, fileUrl: String) throws {
        guard let price = Double(price),
              let rating = Double(rating),
              let ratingCount = Int(ratingCount) else {
            throw Abort(.badRequest, reason: "Invalid format for numeric fields.")
        }
        self.init(id: id ?? UUID(),
                  price: price,
                  book: book,
                  rating: rating,
                  ratingCount: ratingCount,
                  fileUrl: fileUrl)
    }
    
    init(id: UUID? = nil, price: Double, book: Book, rating: Double, ratingCount: Int, fileUrl: String) {
        self.id = id
        self.price = price
        self.book = book
        self.rating = rating
        self.ratingCount = ratingCount
        self.fileUrl = fileUrl
    }
}
