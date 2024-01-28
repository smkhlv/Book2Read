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
    
//    @Field(key: "price")
//    var price: Double
//    
//    @Field(key: "progress")
//    var progress: Double?
//    
//    @Field(key: "rating")
//    var rating: Double?
//    
//    @Field(key: "publishDate")
//    var publishDate: Date
//    
//    @Field(key: "ratingCount")
//    var ratingCount: Int
//    
//    @Field(key: "description")
//    var description: String
//    
//    @Field(key: "isPaperVersionAvaliable")
//    var isPaperVersionAvaliable: Bool
//    
//    @Field(key: "pageCount")
//    var pageCount: Int
//    
//    @Field(key: "isAudibleAvaliable")
//    var isAudibleAvaliable: Bool
//
//    @Field(key: "backCoverText")
//    var backCoverText: String
//    
//    @Field(key: "coverImageUrl")
//    var coverImageUrl: String
//    
//    @Field(key: "authorName")
//    var authorName: String
    
    init() { }

    init(id: UUID? = nil, isbn: Int, title: String, genre: String) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.genre = genre
    }
}
