import Vapor
import FluentPostgreSQL


final class actor: Codable {
    var id: Int?
    var first_name: String
    var last_name: String
    var last_update: Date
    
    init(first_name: String, last_name: String) {
        self.first_name = first_name
        self.last_name = last_name
        self.last_update = Date()
    }
}

//extension actor: Preparation {
//    static func prepare(_ database: .psql) throws {}
//    static func revert(_ database: .psql) throws {}
//}

extension actor: Content {}
extension actor: Migration {}
extension actor: PostgreSQLModel {
//    defaultDatabase: DatabaseIdentifier<PostgreSQLDatabase>
}
