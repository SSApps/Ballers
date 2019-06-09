import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
   
    
    let usersController = UsersController()
    
    try router.register(collection: usersController)
    
    let courtController = CourtController()
    
    try router.register(collection: courtController)
    
   
}


    

