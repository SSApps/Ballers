
import Vapor
import FluentPostgreSQL

final class Court: Codable {
    
    
    var id: UUID?
    var courtName: String
    var address: String
    var ballers: Int
    
    
    
    init(courtName: String, address: String, id: UUID ){
        
        self.courtName = courtName
        self.address = address
        self.ballers = 0
        
        self.id  = id
        
 
    }
}

extension Court{
    var users: Children<Court, User>{
        return children(\.courtID)
    }
}

extension Court: PostgreSQLUUIDModel {}
extension Court: Migration {}
extension Court: Content {}
extension Court: Parameter {}

//struct AdminCourt: Migration {
//    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
//         return .done(on: conn)
//    }
//    
//    // 2
//    typealias Database = PostgreSQLDatabase
//    // 3
//    static func prepare(on connection: PostgreSQLConnection)
//        -> Future<Void> {
//            // 4
//            
//            
//            // 5
//            let court = Court(courtName: "Mother", address: "123 Fake street", id: UUID())
//            // 6
//            return court.save(on: connection).transform(to: ())
//    }
//}
