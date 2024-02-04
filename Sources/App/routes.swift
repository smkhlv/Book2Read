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

    app.routes.defaultMaxBodySize = "100mb"
}
