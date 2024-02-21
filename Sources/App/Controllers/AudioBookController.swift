//
//  AudioBookController.swift
//
//
//  Created by Sergei on 4.2.24..
//

import Fluent
import Vapor

struct AudioBookController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let audioBooksRoute = routes.grouped("audioBooks")
        let tokenProtected = audioBooksRoute.grouped(Token.authenticator())

        tokenProtected.post("create", use: create)
        tokenProtected.get(":bookId", use: getDetail)
        tokenProtected.get(":bookId", "download", use: downloadBook)
    }

    private func getDetail(req: Request) async throws -> AudioBook {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid AudioBook ID")
        }

        return try await AudioBook.find(bookId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .get()
    }

    private func create(req: Request) async throws -> HTTPStatus {
        let audioBookDto = try req.content.decode(AudioBookDto.self)
        guard let parentBook = try await Book.find(UUID(uuidString: audioBookDto.bookId), on: req.db) else {
            throw Abort(.badRequest, reason: "Can't find parent book")
        }

        let file = audioBookDto.file

        let uploadPath = req.application.directory.workingDirectory + "uploads/audiobooks/"
        let filename = UUID().uuidString
        let fileUrl = uploadPath + filename

        do {
            try FileManager.default.createDirectory(atPath: uploadPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create directory: \(error.localizedDescription)")
        }

        do {
            try await req.fileio.writeFile(file.data, at: fileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to write file: \(error.localizedDescription)")
        }

        let bookData = try AudioBook(price: audioBookDto.price,
                                     book: parentBook,
                                     rating: audioBookDto.rating,
                                     ratingCount: audioBookDto.ratingCount,
                                     fileUrl: fileUrl)
        try await bookData.save(on: req.db)

        return .created
    }

    private func downloadBook(req: Request) async throws -> Response {
        guard let bookId = req.parameters.get("bookId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid AudioBook ID")
        }

        do {
            guard let book = try await AudioBook.find(bookId, on: req.db) else {
                throw Abort(.notFound, reason: "Book \(bookId) is not found")
            }

            let fileUrl = book.fileUrl
            return req.fileio.streamFile(at: fileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to find a book \(bookId): \(error.localizedDescription)")
        }
    }
}
