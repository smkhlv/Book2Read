import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "Book2Read"
    }

    try app.register(collection: UserController())
}
