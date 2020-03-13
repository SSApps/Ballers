
import Foundation
import Vapor
import FluentPostgreSQL
import Authentication


final class User: Codable, Equatable{
    
    
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var courtID: Court.ID?
    
    
    init(name: String, username: String, password: String, courtID: Court.ID?) {
        self.name = name
        self.username = username
        self.password = password
        self.courtID = courtID
    
        
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        if (lhs.id == rhs.id){
            return true
        } else{
            return false
        }
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var courtID: Court.ID?
        
        init(id: UUID?, name : String, username: String, courtID: Court.ID?) {
            self.id = id
            self.name = name
            self.username = username
            self.courtID = courtID
        }
    }
}


extension User: PostgreSQLUUIDModel{}
extension User: Content {}
extension User: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}
extension User: Parameter {}
extension User.Public: Content{}
extension User {
    
    var court: Parent<User, Court>{
        return parent(\.courtID)!
    }
    
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, courtID: courtID)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self){ user in
            return user.convertToPublic()
        }
    }
}
extension User: BasicAuthenticatable{
    static var passwordKey: WritableKeyPath<User, String> = \User.password
    static let usernameKey: WritableKeyPath<User, String> = \User.username
}
extension User: TokenAuthenticatable {
    // 2
    typealias TokenType = Token
}

struct AdminUser: Migration {
    // 2
    typealias Database = PostgreSQLDatabase
    // 3
    static func prepare(on connection: PostgreSQLConnection)
        -> Future<Void> {
            // 4
            let password = try? BCrypt.hash("password")
            guard let hashedPassword = password else {
                fatalError("Failed to create admin user")
            }
            var court: Court?
           // for _ in 1..<10{
                 court = Court(courtName: "24 Hour Fitness Nordhoff", address: "19350 Nordhoff St Unit D, Northridge, CA 91324", id: UUID(),latitude: 34.234150, longitude: -118.555649)
            // 6
                    court?.create(on: connection)
            
            court = Court(courtName: "Crunch Fitness Nordhoff", address: "20914 Nordhoff St, Chatsworth, CA 91311", id: UUID(),latitude: 34.234791, longitude: -118.589310)
                      // 6
                              court?.create(on: connection)
            court = Court(courtName: "24 Hour Fitness Topanga", address: "6220 CA-27 #2410, Woodland Hills, CA 91367", id: UUID(),latitude: 34.183510, longitude: -118.605870)
                      // 6
                              court?.create(on: connection)
            court = Court(courtName: "LA Fitness Woodland Hills", address: "6401 Canoga Ave, Woodland Hills, CA 9136", id: UUID(),latitude: 34.187260, longitude: -118.597810)
                      // 6
                              court?.create(on: connection)
            court = Court(courtName: "LA Fitness Northridge", address: "18679 Devonshire St, Northridge, CA 91324", id: UUID(),latitude: 34.258511, longitude: -118.539993)
                      // 6
                              court?.create(on: connection)	
            // 5
          //  }
            let user = User(
                name: "Admin",
                username: "admin",
                password: hashedPassword,
                courtID: court!.id)
            
            // 6
            return user.save(on: connection).transform(to: ())
            
    }
    // 7
    static func revert(on connection: PostgreSQLConnection)
        -> Future<Void> {
            return .done(on: connection)
    }
}//G2geoJVqioEgtIlTmBeePQ==


