//
//  Book.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Fluent
import Vapor

final class Book: Model, Content {
    static let schema = "books"

    @ID
    var id: UUID?

    @Field(key: "isbn")
    var isbn: String
    
    @OptionalChild(for: \.$book)
    var audioBook: AudioBook?

    @Field(key: "title")
    var title: String

    @Field(key: "genre")
    var genre: String

    @Field(key: "price")
    var price: Double

    @Field(key: "rating")
    var rating: Double

    @Field(key: "publishDate")
    var publishDate: Date

    @Field(key: "ratingCount")
    var ratingCount: Int

    @Field(key: "description")
    var description: String

    @Field(key: "isPaperVersionAvailable")
    var isPaperVersionAvailable: Bool

    @Field(key: "pageCount")
    var pageCount: Int

    @Field(key: "isAudibleAvailable")
    var isAudibleAvailable: Bool

    @Field(key: "backCoverText")
    var backCoverText: String

    @Field(key: "coverImageUrl")
    var coverImageUrl: String

    @Field(key: "authorId")
    var authorId: UUID

    @Field(key: "fileUrl")
    var fileUrl: String
    
    @Field(key: "language")
    var language: String

    init() {}

    init(id: UUID? = nil,
         isbn: String,
         title: String,
         genre: String,
         price: Double,
         rating: Double,
         publishDate: Date,
         ratingCount: Int,
         description: String,
         isPaperVersionAvailable: Bool,
         pageCount: Int,
         isAudibleAvailable: Bool,
         backCoverText: String,
         coverImageUrl: String,
         authorId: UUID,
         fileUrl: String)
    {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.genre = genre
        self.price = price
        self.rating = rating
        self.publishDate = publishDate
        self.ratingCount = ratingCount
        self.description = description
        self.isPaperVersionAvailable = isPaperVersionAvailable
        self.pageCount = pageCount
        self.isAudibleAvailable = isAudibleAvailable
        self.backCoverText = backCoverText
        self.coverImageUrl = coverImageUrl
        self.authorId = authorId
        self.fileUrl = fileUrl
    }
}

extension Book {
    struct SearchBookQuery: Content {
        let title: String?
        let genre: String?
    }
}

extension Book {
    convenience init(from bookDto: BookDto, withFileUrl fileUrl: String) throws {
        guard let price = Double(bookDto.price),
              let rating = Double(bookDto.rating),
              let ratingCount = Int(bookDto.ratingCount),
              let pageCount = Int(bookDto.pageCount)
        else {
            throw Abort(.badRequest, reason: "Invalid format for numeric fields.")
        }

        guard let publishDate = DateFormatter.bookDateFormatter.date(from: bookDto.publishDate) else {
            throw Abort(.badRequest, reason: "Invalid format for date fields.")
        }

        guard let isPaperVersionAvailable = Bool(bookDto.isPaperVersionAvailable),
              let isAudibleAvailable = Bool(bookDto.isAudibleAvailable)
        else {
            throw Abort(.badRequest, reason: "Invalid format for bool fields.")
        }

        self.init(
            isbn: bookDto.isbn,
            title: bookDto.title,
            genre: bookDto.genre,
            price: price,
            rating: rating,
            publishDate: publishDate,
            ratingCount: ratingCount,
            description: bookDto.description,
            isPaperVersionAvailable: isPaperVersionAvailable,
            pageCount: pageCount,
            isAudibleAvailable: isAudibleAvailable,
            backCoverText: bookDto.backCoverText,
            coverImageUrl: bookDto.coverImageUrl,
            authorId: UUID(uuidString: bookDto.authorId) ?? UUID(),
            fileUrl: fileUrl
        )
    }
}
