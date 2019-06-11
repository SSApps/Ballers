
import Vapor
import FluentPostgreSQL

final class Court: Codable {
    
    
    var id: Int?
    var courtName: String
    var address: String
    var ballers: Int
   // var users: [User.ID]?
    
    
    init(courtName: String, address: String ){
        
        self.courtName = courtName
        self.address = address
        self.ballers = 0
       // self.users = users
        //
 
    }
}

extension Court: PostgreSQLModel {}
extension Court: Migration {}
extension Court: Content {}
extension Court: Parameter {}
