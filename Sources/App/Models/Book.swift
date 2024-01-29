//
//  File.swift
//  
//
//  Created by Sergei on 25.1.24..
//

import Vapor
import Fluent

final class Book: Model, Content {
    static let schema = "books"
    
    @ID
    var id: UUID?

    @Field(key: "isbn")
    var isbn: Int
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "genre")
    var genre: String
    
    @Field(key: "price")
    var price: Double?
    
    @Field(key: "rating")
    var rating: Double?
    
    @Field(key: "publishDate")
    var publishDate: Date?
    
    @Field(key: "ratingCount")
    var ratingCount: Int?
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "isPaperVersionAvaliable")
    var isPaperVersionAvaliable: Bool?
    
    @Field(key: "pageCount")
    var pageCount: Int?
    
    @Field(key: "isAudibleAvaliable")
    var isAudibleAvaliable: Bool?

    @Field(key: "backCoverText")
    var backCoverText: String?
    
    @Field(key: "coverImageUrl")
    var coverImageUrl: String?
    
    @Field(key: "authorName")
    var authorName: String?
    
    @Field(key: "bookData")
    var bookData: Data?
    
    init() { }

    init(id: UUID? = nil, isbn: Int, title: String, genre: String, price: Double? = nil, rating: Double? = nil, publishDate: Date? = nil, ratingCount: Int? = nil, description: String? = nil, isPaperVersionAvaliable: Bool? = nil, pageCount: Int? = nil, isAudibleAvaliable: Bool? = nil, backCoverText: String? = nil, coverImageUrl: String? = nil, authorName: String? = nil, bookData: Data? = nil) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.genre = genre
        self.price = price
        self.rating = rating
        self.publishDate = publishDate
        self.ratingCount = ratingCount
        self.description = description
        self.isPaperVersionAvaliable = isPaperVersionAvaliable
        self.pageCount = pageCount
        self.isAudibleAvaliable = isAudibleAvaliable
        self.backCoverText = backCoverText
        self.coverImageUrl = coverImageUrl
        self.authorName = authorName
        self.bookData = bookData
    }

    func asInformation() -> Information {
        return Information(
            title: title,
            genre: genre,
            description: description,
            price: price,
            rating: rating,
            publishDate: publishDate,
            ratingCount: ratingCount,
            isPaperVersionAvaliable: isPaperVersionAvaliable,
            pageCount: pageCount,
            isAudibleAvaliable: isAudibleAvaliable,
            backCoverText: backCoverText,
            coverImageUrl: coverImageUrl,
            authorName: authorName
        )
    }
}

extension Book {
    struct Information: Content {
        let title: String?
        let genre: String?
        let description: String?
        let price: Double?
        let rating: Double?
        let publishDate: Date?
        let ratingCount: Int?
        let isPaperVersionAvaliable: Bool?
        let pageCount: Int?
        let isAudibleAvaliable: Bool?
        let backCoverText: String?
        let coverImageUrl: String?
        let authorName: String?
    }

    struct SearchBookQuery: Content {
        let title: String?
        let genre: String?
        let description: String?
        let authorName: String?
    }
}
