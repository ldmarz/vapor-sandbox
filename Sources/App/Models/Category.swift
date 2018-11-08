import Vapor
import FluentPostgreSQL


final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Parameter {}
extension Category: Migration {}
extension Category: Content {}
