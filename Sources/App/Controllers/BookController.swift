//
//  BookController.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Fluent
import Vapor

struct BookController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let booksRoute = routes.grouped("books")
        let tokenProtected = booksRoute.grouped(Token.authenticator())

        tokenProtected.get("all", use: getAllBooks)
        tokenProtected.get(":itemID", use: getDetail)
        tokenProtected.get("find", use: findBook)
        tokenProtected.post("create", use: create)
        tokenProtected.get(":itemID", "download", use: downloadBook)
    }

    private func getAllBooks(req: Request) throws -> EventLoopFuture<[Book]> {
        Book.query(on: req.db)
            .paginate(for: req)
            .map { page in
                page.items
            }
    }

    private func getDetail(req: Request) async throws -> Book {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        return try await Book.find(itemID, on: req.db).unsafelyUnwrapped
    }

    private func findBook(req: Request) throws -> EventLoopFuture<[Book]> {
        let searchQuery = try req.query.decode(Book.SearchBookQuery.self)
        return Book.query(on: req.db)
            .group(.or) { or in
                if let title = searchQuery.title {
                    or.filter(\.$title == title)
                }
                if let genre = searchQuery.genre {
                    or.filter(\.$genre == genre)
                }
            }
            .paginate(for: req)
            .map { page in
                page.items
            }
    }

    private func create(req: Request) async throws -> HTTPStatus {
        let bookDto = try req.content.decode(BookDto.self)
        let file = bookDto.file

        let uploadPath = req.application.directory.workingDirectory + "uploads/books/"
        let filename = file.filename
        let fileUrl = uploadPath + filename

        let bookData = try Book(from: bookDto, withFileUrl: fileUrl)
        try await bookData.save(on: req.db)

        do {
            try await req.fileio.writeFile(file.data, at: fileUrl)

            return .created
        } catch {
            throw Abort(.internalServerError, reason: "Failed to write file: \(error)")
        }
    }

    private func downloadBook(req: Request) async throws -> Response {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        do {
            guard let book = try await Book.find(itemID, on: req.db) else {
                throw Abort(.notFound, reason: "Book \(itemID) is not found")
            }

            let fileUrl = book.fileUrl

            return req.fileio.streamFile(at: fileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to find a book \(itemID): \(error)")
        }
    }
}
