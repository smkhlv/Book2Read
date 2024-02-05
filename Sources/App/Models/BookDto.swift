//
//  BookDto.swift
//
//
//  Created by Igoryok on 01.02.2024.
//

import Vapor

struct BookDto: Content {
    var isbn: String
    var title: String
    var genre: String
    var price: String
    var rating: String
    var publishDate: String
    var ratingCount: String
    var description: String
    var isPaperVersionAvailable: String
    var pageCount: String
    var isAudibleAvailable: String
    var backCoverText: String
    var coverImageFile: File
    var authorId: String
    var language: String
    let file: File
}
