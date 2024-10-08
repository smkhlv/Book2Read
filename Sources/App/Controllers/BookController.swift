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
        tokenProtected.get("ids", use: getBooksByIds)
    }

    private func getAllBooks(req: Request) async throws -> [Book] {
        try await Book.query(on: req.db)
            .paginate(for: req)
            .map { page in
                page.items
            }
            .get()
    }

    private func getDetail(req: Request) async throws -> Book {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid book ID")
        }

        return try await Book.find(bookId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .get()
    }

    private func findBook(req: Request) async throws -> [Book] {
        let searchQuery = try req.query.decode(Book.SearchBookQuery.self)

        return try await Book.query(on: req.db)
            .group(.and) { and in
                if let title = searchQuery.title {
                    and.filter(\.$title, .custom("ILIKE"), "%\(title)%")
                }
                if let genre = searchQuery.genre {
                    and.filter(\.$genre == genre)
                }
            }
            .paginate(for: req)
            .map { page in
                page.items
            }
            .get()
    }

    private func create(req: Request) async throws -> HTTPStatus {
        let bookDto = try req.content.decode(BookDto.self)
        let bookFile = bookDto.file
        let coverImageFile = bookDto.coverImageFile

        let bookUploadPath = req.application.directory.resourcesDirectory + "books/"
        let bookFileExtension = bookFile.extension.map { ".\($0)" } ?? ""
        let bookFileName = UUID().uuidString + bookFileExtension
        let bookFileUrl = bookUploadPath + bookFileName

        let coverImageUploadPath = req.application.directory.resourcesDirectory + "bookCovers/"
        let coverImageFileExtension = coverImageFile.extension.map { ".\($0)" } ?? ""
        let coverImageFileName = UUID().uuidString + coverImageFileExtension
        let coverImageFileUrl = coverImageUploadPath + coverImageFileName

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

        let downloadCoverImageUrl = "\(Book.schema)/coverImages/\(coverImageFileName)"

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

    private func getBooksByIds(req: Request) throws -> EventLoopFuture<[Book]> {
        guard let bookIds = req.query["ids"].flatMap({ (ids: String) -> [String] in
            ids.components(separatedBy: ",")
        }) else {
            throw Abort(.badRequest, reason: "Book IDs are missing in the request")
        }

        let uuids = bookIds.compactMap { UUID($0) }

        return Book.query(on: req.db)
            .filter(\.$id ~~ uuids)
            .all()
    }
}
