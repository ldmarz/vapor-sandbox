import Foundation
import FluentPostgreSQL
import Vapor
////
////  08-11-2017-1addMockField.swift
////  App
////
////  Created by Lenin Martinez on 11/8/18.
////
struct AddUniqueToUsername: Migration {
    typealias Database = PostgreSQLDatabase

    static func prepare( on connection: PostgreSQLConnection ) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.unique(on: \.username)
        }
    }

    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteUnique(from: \.username)
        }
    }
}
