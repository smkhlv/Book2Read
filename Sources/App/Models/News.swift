//
//  News.swift
//
//
//  Created by Igoryok on 21.02.2024.
//

import Foundation

import Fluent
import Vapor

final class News: Model, Content {
    static let schema = "news"

    @ID
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "imageUrl")
    var imageUrl: String

    @Field(key: "language")
    var language: String

    init() {}

    init(id: UUID? = nil,
         title: String,
         imageUrl: String,
         language: String)
    {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.language = language
    }
}

extension News {
    convenience init(from newsDto: NewsDto, withImageUrl imageUrl: String) throws {
        self.init(title: newsDto.title, imageUrl: imageUrl, language: newsDto.language)
    }
}
