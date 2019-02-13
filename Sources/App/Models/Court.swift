
import Vapor
import FluentSQLite

final class Court: Codable {
    
    
    var id: Int?
    var courtName: String
    var address: String
    var ballers: Int
    
    
    init(courtName: String, address: String){
        
        self.courtName = courtName
        self.address = address
        self.ballers = 0
        print("")
    }
}

extension Court: SQLiteModel {}
extension Court: Migration {}
extension Court: Content {}
