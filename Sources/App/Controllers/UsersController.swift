
import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
    
        usersRoute.get( use: getAllHandler)
        
        usersRoute.get(User.parameter, use: getHandler)
       // usersRoute.put(User.parameter, Court.parameter, use: UpdateHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        
        basicAuthGroup.post("login", use: loginHandler)
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        tokenAuthGroup.post(User.self, use: createHandler)
        tokenAuthGroup.put(User.parameter, Court.parameter, use: UpdateHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public>   {
        
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func loginHandler(_ req: Request)throws -> Future<Token> {
        
        
        let user = try req.requireAuthenticated(User.self)
        print("Login \(user.convertToPublic().name)")
        let token = try Token.generate(for: user)
        
        return token.save(on: req)
    }
    
    func UpdateHandler(_ req: Request)throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.parameters.next(Court.self)){
            user, court in
            user.courtID = court.id
            return user.save(on: req)
        }
    }
}


