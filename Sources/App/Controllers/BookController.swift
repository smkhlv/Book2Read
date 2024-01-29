//
//  BookController.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Vapor
import Fluent

struct BookController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let booksRoute = routes.grouped("books")
        let tokenProtected = booksRoute.grouped(Token.authenticator())
        
        tokenProtected.post("create", use: create)
        tokenProtected.get("find", use: findBook)
        tokenProtected.get("all", use: getAllBooks)
        tokenProtected.get(":itemID", use: getDetail)
    }
    
    func create(req: Request) async throws -> Book.Information {
        let bookData = try req.content.decode(Book.self)
        try await bookData.save(on: req.db)
        return bookData.asInformation()
    }
    
    func findBook(req: Request) throws -> EventLoopFuture<[Book.Information]> {
        let searchQuery = try req.query.decode(Book.SearchBookQuery.self)
        return Book.query(on: req.db)
            .group(.or) { or in
                if let title = searchQuery.title {
                    or.filter(\.$title == title)
                }
                if let genre = searchQuery.genre {
                    or.filter(\.$genre == genre)
                }
                if let description = searchQuery.description {
                    or.filter(\.$description == description)
                }
                if let authorName = searchQuery.authorName {
                    or.filter(\.$authorName == authorName)
                }
            }
            .paginate(for: req)
            .map { page in
                page.items.map { $0.asInformation() }
            }
    }
    
    func getAllBooks(req: Request) throws -> EventLoopFuture<[Book.Information]> {
        return Book.query(on: req.db)
            .paginate(for: req)
            .map { page in
                page.items.map { $0.asInformation() }
            }
    }
    
    func getDetail(req: Request) async throws -> Book {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }
        return try await Book.find(itemID, on: req.db).unsafelyUnwrapped
    }
}
