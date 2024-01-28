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
    }
    
    func create(req: Request) async throws -> Book {
        let bookData = try req.content.decode(Book.self)
        try await bookData.save(on: req.db)
        return bookData
    }
    
    func findBook(req: Request) throws -> EventLoopFuture<[Book]> {
        let searchQuery = try req.query.decode(SearchBookQuery.self)
        return Book.query(on: req.db)
            .group(.or) { or in
                if let title = searchQuery.title {
                    or.filter(\.$title == title)
                }
                if let genre = searchQuery.genre {
                    or.filter(\.$genre == genre)
                }
//                if let description = searchQuery.description {
//                    or.filter(\.$description == description)
//                }
//                if let authorName = searchQuery.authorName {
//                    or.filter(\.$authorName == authorName)
//                }
            }
            .paginate(for: req)
            .map { page in
                page.items
            }
    }
    
    func getAllBooks(req: Request) throws -> EventLoopFuture<[Book]> {
        return Book.query(on: req.db)
            .paginate(for: req)
            .map { page in
                page.items
            }
    }
}

struct SearchBookQuery: Content {
    let title: String?
    let genre: String?
    let description: String?
    let authorName: String?
}
