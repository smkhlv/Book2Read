//
//  File.swift
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
        tokenProtected.get(":itemID", use: getDetail)
        tokenProtected.get(":itemID", "download", use: downloadBook)
    }
    
    private func getDetail(req: Request) async throws -> AudioBook {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid AudioBook ID")
        }

        return try await AudioBook.find(itemID, on: req.db).unsafelyUnwrapped
    }
    
    private func create(req: Request) async throws -> HTTPStatus {
        let audioBookDto = try req.content.decode(AudioBookDto.self)
        guard let parentBook = try await Book.find(UUID(uuidString: audioBookDto.bookId), on: req.db) else {
            throw Abort(.badRequest, reason: "Can't find parent book")
        }

        let file = audioBookDto.file

        let uploadPath = req.application.directory.workingDirectory + "uploads/audiobooks/"
        let filename = file.filename
        let fileUrl = uploadPath + filename

        let bookData = try AudioBook(price: audioBookDto.price,
                                     book: parentBook,
                                     rating: audioBookDto.rating,
                                     ratingCount: audioBookDto.ratingCount,
                                     fileUrl: fileUrl)
        try await bookData.save(on: req.db)

        do {
            try FileManager.default.createDirectory(atPath: uploadPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create directory: \(error)")
        }

        do {
            try await req.fileio.writeFile(file.data, at: fileUrl)
            return .created
        } catch {
            throw Abort(.internalServerError, reason: "Failed to write file: \(error)")
        }
    }

    private func downloadBook(req: Request) async throws -> Response {
        guard let itemID = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid AudioBook ID")
        }

        do {
            guard let book = try await AudioBook.find(itemID, on: req.db) else {
                throw Abort(.notFound, reason: "Book \(itemID) is not found")
            }

            let fileUrl = book.fileUrl
            return req.fileio.streamFile(at: fileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to find a book \(itemID): \(error)")
        }
    }
}
