import Vapor

struct AudioBookDto: Content {
    var bookId: String // UUID to parent book
    var price: String
    var rating: String
    var ratingCount: String
    let file: File
}
