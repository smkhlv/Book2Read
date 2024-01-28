//
//  Author.swift
//
//
//  Created by Sergei on 25.1.24..
//

import Vapor
import Fluent

final class Author: Model, Content {
    
    static let schema = "authors"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
