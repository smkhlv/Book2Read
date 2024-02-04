//
//  File.swift
//  
//
//  Created by Sergei on 4.2.24..
//

import Vapor

struct ReadingProgressController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let readingProgressRoutes = routes.grouped("reading-progress")
        let tokenProtected = readingProgressRoutes.grouped(Token.authenticator())
        
        tokenProtected.post(use: addReadingProgress)
        tokenProtected.put(":readingProgressID", use: updateReadingProgress)
        tokenProtected.delete(":readingProgressID", use: deleteReadingProgress)
    }
    
    func addReadingProgress(req: Request) async throws -> ReadingProgress {
        let readingProgress = try req.content.decode(ReadingProgress.self)
        try await readingProgress.save(on: req.db)
        return readingProgress
    }
    
    func updateReadingProgress(req: Request) async throws -> HTTPStatus {
        let updatedProgress = try req.content.decode(ReadingProgress.self)
        guard let readingProgress = try await ReadingProgress.find(req.parameters.get("readingProgressID"), on: req.db) else {
            throw Abort(.notFound)
        }
        readingProgress.currentPage = updatedProgress.currentPage
        readingProgress.lastUpdate = updatedProgress.lastUpdate
        try await readingProgress.save(on: req.db)
        return .ok
    }
    
    func deleteReadingProgress(req: Request) async throws -> HTTPStatus {
        guard let readingProgress = try await ReadingProgress.find(req.parameters.get("readingProgressID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await readingProgress.delete(on: req.db)
        return .noContent
    }
}

