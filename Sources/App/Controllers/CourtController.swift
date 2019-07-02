
import Vapor
import Crypto
import Authentication

struct CourtController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let courtRoute = router.grouped("api", "court")
        
        courtRoute.post(use: createHandler)
        courtRoute.get(use: getAllHandler)
        
        courtRoute.get(Court.parameter, use: getHandler)
        courtRoute.get(Court.parameter,"users", use: getUsersHandler)
        courtRoute.get(Court.parameter, "ballers", use: getBallersHandler)
        //courtRoute.put(Court.parameter, use: checkInHandler)
        
        
        
       // let protected = courtRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        //protected.get( use: getAllHandler)
        //protected.put("check", Court.parameter, use: checkInHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        // 2
        let tokenAuthGroup = courtRoute.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        // 3
        tokenAuthGroup.put(Court.parameter,"checkin",User.parameter, use: checkInHandler)
        tokenAuthGroup.put(Court.parameter,"checkout",User.parameter, use: checkOutHandler)
        //tokenAuthGroup.get(use: getAllHandler)
        //tokenAuthGroup.post(use: createHandler)
        //tokenAuthGroup.get(User.parameter, use: getHandler)
        
    }
    
    
    func createHandler(_ req: Request) throws ->Future<Court>   {
        
        return try req.content.decode(Court.self).flatMap(to: Court.self){
            court in
            print("Saving \(court.courtName) to database")
            return court.create(on: req)
        }
        
        
    }
    
    
    func getAllHandler(_ req: Request) throws -> Future<[Court]> {
            
                return Court.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Court> {
        
        return try req.parameters.next(Court.self)
    }
    
    func checkInHandler(_ req: Request)throws -> Future<Court>{
        return try flatMap(to:Court.self, req.parameters.next(Court.self),req.parameters.next(User.self) ){
            
            court, user in
            court.ballers = court.ballers + 1
            
           
            
            
           
            return court.save(on: req)
        }
    }
    
    func checkOutHandler(_ req: Request)throws -> Future<Court>{
        return try flatMap(to:Court.self, req.parameters.next(Court.self), req.parameters.next(User.self) ){
            
            court, user in
            
            court.ballers = court.ballers - 1
            return court.save(on: req)
        }
    }
   
    func getUsersHandler(_ req: Request)throws -> Future<[User.Public]> {
        
        return try req.parameters.next(Court.self).flatMap(to: [User.Public].self) {
            court in
            return try court.users.query(on: req).decode(data: User.Public.self).all()
            
        }
    }
    
    func getBallersHandler(_ req: Request)throws -> Future<CheckInData>{
        return try req.parameters.next(Court.self).flatMap(to: CheckInData.self){
            court in
            let usersFuture = try court.users.query(on: req).all()
            let ballersFuture = usersFuture.map(to: CheckInData.self){
                users in
                let checkInData = CheckInData(ballers: users.count)
                return checkInData
                
            }
            
            return ballersFuture
        }
    }
    
    
}

final class CheckInData: Content,Codable {
   var ballers: Int
    
    init(ballers: Int) {
        self.ballers = ballers
    }
}
