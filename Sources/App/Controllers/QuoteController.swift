import Vapor
import Fluent

struct QuotesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let quotesRoutes = routes.grouped("quotes")
        let tokenProtected = quotesRoutes.grouped(Token.authenticator())
        
        tokenProtected.post(use: addQuote)
        tokenProtected.put(":quoteID", use: updateQuote)
        tokenProtected.delete(":quoteID", use: deleteQuote)
        tokenProtected.get("forBook", use: getQuotesForBook)
    }
    
    func addQuote(req: Request) async throws -> Quote {
        let quote = try req.content.decode(Quote.self)
        try await quote.save(on: req.db)
        return quote
    }
    
    func getQuotesForBook(req: Request) async throws -> [Quote] {
        let searchQuery = try req.query.decode(Quote.Public.self)
        return try await Quote.query(on: req.db)
            .group(.and) { and in
                and.filter(\.$user.$id == searchQuery.userId)
                if let bookId = searchQuery.bookId {
                    and.filter(\.$book.$id == bookId)
                }
            }
            .all()
    }
    
    func updateQuote(req: Request) async throws -> HTTPStatus {
        let updatedQuote = try req.content.decode(Quote.self)
        guard let quote = try await Quote.find(req.parameters.get("quoteID"), on: req.db) else {
            throw Abort(.notFound)
        }
        quote.quoteText = updatedQuote.quoteText
        quote.pageNumber = updatedQuote.pageNumber
        try await quote.save(on: req.db)
        return .ok
    }
    
    func deleteQuote(req: Request) async throws -> HTTPStatus {
        guard let quote = try await Quote.find(req.parameters.get("quoteID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await quote.delete(on: req.db)
        return .noContent
    }
}

