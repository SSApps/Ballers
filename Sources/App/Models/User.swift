
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
            let court = Court(courtName: "Mother", address: "123 Fake street", id: UUID())
            // 6
            court.create(on: connection)            // 5
            let user = User(
                name: "Admin",
                username: "admin",
                password: hashedPassword,
                courtID: court.id)
            // 6
            return user.save(on: connection).transform(to: ())
    }
    // 7
    static func revert(on connection: PostgreSQLConnection)
        -> Future<Void> {
            return .done(on: connection)
    }
}//G2geoJVqioEgtIlTmBeePQ==


