import FluentPostgreSQL
import Vapor


struct AddForeignPivot: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare( on connection: PostgreSQLConnection ) -> Future<Void> {
        return Database.update(AcronymCategoryPivot.self, on: connection) { builder in
            builder.reference(
                from: \.acronymID,
                to: \Acronym.id,
                onDelete: .cascade
            )
            
            builder.reference(
                from: \.categoryID,
                to: \Category.id,
                onDelete: .cascade
            )
        }
    }

    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(AcronymCategoryPivot.self, on: connection) { builder in
            builder.deleteReference(from: \.acronymID, to: \Acronym.id)
            builder.deleteReference(from: \.categoryID, to: \Category.id)
        }
    }
}
