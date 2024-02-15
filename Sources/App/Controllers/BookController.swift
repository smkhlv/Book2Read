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
        let scheme = Book.schema
        let schemePath = PathComponent(stringLiteral: scheme)

        let booksRoute = routes.grouped(schemePath)
        let tokenProtected = booksRoute.grouped(Token.authenticator())

        tokenProtected.get("all", use: getAllBooks)
        tokenProtected.get(":bookId", use: getDetail)
        tokenProtected.get("find", use: findBook)
        tokenProtected.post("create", use: create)
        tokenProtected.get(":bookId", "download", use: downloadBook)
        tokenProtected.delete("delete", ":bookId", use: deleteBook)
        tokenProtected.get("coverImages", ":name", use: downloadCoverImage)
    }

    private func getAllBooks(req: Request) throws -> EventLoopFuture<[Book]> {
        Book.query(on: req.db)
            .paginate(for: req)
            .map { page in
                page.items
            }
    }

    private func getDetail(req: Request) async throws -> Book {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        return try await Book.find(bookId, on: req.db).unsafelyUnwrapped
    }

    private func findBook(req: Request) throws -> EventLoopFuture<[Book]> {
        let searchQuery = try req.query.decode(Book.SearchBookQuery.self)
        return Book.query(on: req.db)
            .group(.or) { or in
                if let title = searchQuery.title {
                    or.filter(\.$title ~~ title)
                }
                if let genre = searchQuery.genre {
                    or.filter(\.$genre ~= genre)
                }
            }
            .paginate(for: req)
            .map { page in
                page.items
            }
    }

    private func create(req: Request) async throws -> HTTPStatus {
        let bookDto = try req.content.decode(BookDto.self)
        let bookFile = bookDto.file
        let coverImageFile = bookDto.coverImageFile

        let bookUploadPath = req.application.directory.resourcesDirectory + "books/"
        let bookFilename = bookFile.filename
        let bookFileUrl = bookUploadPath + bookFilename

        let coverImageUploadPath = req.application.directory.resourcesDirectory + "bookCovers/"
        let coverImageFilename = coverImageFile.filename
        let coverImageFileUrl = coverImageUploadPath + coverImageFilename

        do {
            try FileManager.default.createDirectory(atPath: bookUploadPath, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: coverImageUploadPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create directory: \(error.localizedDescription)")
        }

        do {
            try await req.fileio.writeFile(bookFile.data, at: bookFileUrl)
            try await req.fileio.writeFile(coverImageFile.data, at: coverImageFileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to write file: \(error.localizedDescription)")
        }

        let downloadCoverImageUrl = "\(Book.schema)/coverImages/\(coverImageFilename)"

        let bookData = try Book(from: bookDto,
                                withFileUrl: bookFileUrl,
                                coverImageUrl: downloadCoverImageUrl)
        try await bookData.save(on: req.db)

        return .created
    }

    private func downloadBook(req: Request) async throws -> Response {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        guard let book = try? await Book.find(bookId, on: req.db) else {
            throw Abort(.notFound, reason: "Book \(bookId) is not found")
        }

        return req.fileio.streamFile(at: book.fileUrl)
    }

    private func deleteBook(req: Request) async throws -> Response {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        guard let book = try? await Book.find(bookId, on: req.db) else {
            throw Abort(.notFound, reason: "Book \(bookId) is not found")
        }

        do {
            try? FileManager.default.removeItem(atPath: book.fileUrl)

            if let coverImageFilename = URL(string: book.coverImageUrl)?.lastPathComponent {
                let coverImageUploadPath = req.application.directory.resourcesDirectory + "bookCovers/"
                let coverImageFileUrl = coverImageUploadPath + coverImageFilename

                try? FileManager.default.removeItem(atPath: coverImageFileUrl)
            }

            try await book.delete(on: req.db)

            return Response(status: .ok)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to delete the book \(bookId): \(error.localizedDescription)")
        }
    }

    private func downloadCoverImage(req: Request) async throws -> Response {
        guard let imageName = req.parameters.get("name") else {
            throw Abort(.notFound, reason: "Image not found")
        }

        let path = req.application.directory.resourcesDirectory + "bookCovers/" + imageName
        return req.fileio.streamFile(at: path)
    }
}
