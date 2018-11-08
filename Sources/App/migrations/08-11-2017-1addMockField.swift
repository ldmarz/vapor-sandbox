//
//  08-11-2017-1addMockField.swift
//  App
//
//  Created by Lenin Martinez on 11/8/18.
//
import FluentPostgreSQL
import Vapor

struct AddFieldMock: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare( on connection: PostgreSQLConnection ) -> Future<Void> {
        return Database.update(Acronym.self, on: connection) { builder in
            builder.field(for: \.someFIeld)
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Acronym.self, on: connection) { builder in
            builder.deleteField(for: \.someFIeld)
        }
    }
}
