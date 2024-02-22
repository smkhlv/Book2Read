//
//  NewsController.swift
//
//
//  Created by Igoryok on 21.02.2024.
//

import Fluent
import Vapor

struct NewsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let scheme = News.schema
        let schemePath = PathComponent(stringLiteral: scheme)

        let route = routes.grouped(schemePath)
        let protectedRoute = route.grouped(Token.authenticator())

        protectedRoute.get("all", use: getAllNews)
        protectedRoute.get(":newsId", use: getDetail)
        protectedRoute.post("create", use: create)
        protectedRoute.delete("delete", ":newsId", use: deleteNews)
        protectedRoute.delete("delete", use: deleteAllNews)
        protectedRoute.get("images", ":name", use: downloadImage)
    }

    private func getAllNews(req: Request) async throws -> [News] {
        let user = try req.auth.require(User.self)
        let userLanguage = user.language

        return try await News.query(on: req.db)
            .filter(\.$language == userLanguage)
            .all()
    }

    private func getDetail(req: Request) async throws -> News {
        guard let newsId = req.parameters.get("newsId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid news ID")
        }

        return try await News.find(newsId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .get()
    }

    private func create(req: Request) async throws -> HTTPStatus {
        let newsDto = try req.content.decode(NewsDto.self)
        let imageFile = newsDto.imageFile

        let directoryConfig = DirectoryConfiguration.detect()
        let uploadPath = directoryConfig.resourcesDirectory + "newsImages/"
        let fileExtension = imageFile.extension.map { ".\($0)" } ?? ""
        let fileName = UUID().uuidString + fileExtension
        let fileUrl = uploadPath + fileName

        do {
            try FileManager.default.createDirectory(atPath: uploadPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to create directory: \(error.localizedDescription)")
        }

        do {
            try await req.fileio.writeFile(imageFile.data, at: fileUrl)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to write file: \(error.localizedDescription)")
        }

        let downloadImageUrl = "\(News.schema)/images/\(fileName)"

        let newsData = try News(from: newsDto, withImageUrl: downloadImageUrl)
        try await newsData.save(on: req.db)

        return .created
    }

    private func deleteNews(req: Request) async throws -> Response {
        guard let newsId = req.parameters.get("newsId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid news ID")
        }

        guard let news = try? await News.find(newsId, on: req.db) else {
            throw Abort(.notFound, reason: "News \(newsId) is not found")
        }

        do {
            try? FileManager.default.removeItem(atPath: news.imageUrl)
            try await news.delete(on: req.db)

            return Response(status: .ok)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to delete the news \(newsId): \(error.localizedDescription)")
        }
    }

    private func deleteAllNews(req: Request) async throws -> HTTPStatus {
        let news = try await News.query(on: req.db).all()

        for item in news {
            try FileManager.default.removeItem(atPath: item.imageUrl)
            try await item.delete(on: req.db)
        }

        return .ok
    }

    private func downloadImage(req: Request) async throws -> Response {
        guard let imageName = req.parameters.get("name") else {
            throw Abort(.notFound, reason: "Image not found")
        }

        let path = req.application.directory.resourcesDirectory + "newsImages/" + imageName
        return req.fileio.streamFile(at: path)
    }
}
