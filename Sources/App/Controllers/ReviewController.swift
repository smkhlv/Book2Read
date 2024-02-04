import Vapor
import Fluent

struct ReviewController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let reviewRoutes = routes.grouped("reviews")
        reviewRoutes.post(use: addReview)
        reviewRoutes.get(":bookID", use: getReviewsForBook)
        reviewRoutes.delete(":reviewID", use: deleteReview)
    }
    
    func addReview(req: Request) async throws -> Review {
        let review = try req.content.decode(Review.self)
        try await review.save(on: req.db)
        return review
    }
     
    func getReviewsForBook(req: Request) throws -> EventLoopFuture<[Review]> {
        guard let bookID = req.parameters.get("bookID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Review.query(on: req.db)
            .filter(\.$book.$id == bookID)
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
