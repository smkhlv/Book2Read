import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "Book2Read31"
    }

    try app.register(collection: UserController())
    try app.register(collection: BookController())
    try app.register(collection: QuotesController())
    try app.register(collection: ReadingProgressController())
    try app.register(collection: ReviewController())

    app.routes.defaultMaxBodySize = "100mb"
}
