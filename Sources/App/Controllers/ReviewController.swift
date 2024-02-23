import Fluent
import Vapor

struct ReviewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let reviewRoutes = routes.grouped("reviews")

        reviewRoutes.post(use: addReview)
        reviewRoutes.get(":bookID", use: getReviewsForBook)
        reviewRoutes.delete(":reviewID", use: deleteReview)
    }

    func addReview(req: Request) async throws -> HTTPStatus {
        let review = try req.content.decode(Review.self)
        let bookID = review.bookId

        guard let book = try await Book.find(bookID, on: req.db) else {
            throw Abort(.notFound, reason: "Book with ID \(bookID) not found")
        }

        let newRatingCount = book.ratingCount + 1
        let currentTotalRating = book.rating * Double(book.ratingCount)
        let newTotalRating = currentTotalRating + Double(review.rating)
        let newRating = newTotalRating / Double(newRatingCount)

        book.ratingCount = newRatingCount
        book.rating = newRating

        try await book.save(on: req.db)
        try await review.save(on: req.db)

        return .ok
    }

    func getReviewsForBook(req: Request) throws -> EventLoopFuture<[Review]> {
        guard let bookID = req.parameters.get("bookID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Review.query(on: req.db)
            .filter(\.$bookId == bookID)
            .all()
    }

    func deleteReview(req: Request) async throws -> HTTPStatus {
        guard let reviewID = req.parameters.get("reviewID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let review = try await Review.find(reviewID, on: req.db) else {
            throw Abort(.notFound)
        }

        try await review.delete(on: req.db)

        return .noContent
    }
}
