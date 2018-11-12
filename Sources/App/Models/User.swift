import Foundation
import Vapor
import FluentPostgreSQL


final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String,  password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Parameter {}
extension User: Migration {}
extension User: Content {}
extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}
