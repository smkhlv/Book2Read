//
//  NewsDto.swift
//
//
//  Created by Igoryok on 22.02.2024.
//

import Vapor

struct NewsDto: Content {
    var title: String
    var imageFile: File
    var language: String
}
