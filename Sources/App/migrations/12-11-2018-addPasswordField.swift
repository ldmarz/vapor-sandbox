//
//  12-11-2018-addPasswordField.swift
//  App
//
//  Created by Lenin Martinez on 11/12/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct AddUserPassword: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare( on connection: PostgreSQLConnection ) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.password, type: .varchar, .default(.literal("")))
            
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteField(for: \.password)
        }
    }
}
