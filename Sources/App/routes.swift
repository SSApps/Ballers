import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.post("api", "courts"){ req -> Future<Court> in
        return try req.content.decode(Court.self).flatMap(to: Court.self)
        { court in
                return court.save(on: req)
            
        }
    }
    
    
    router.get("api", "courts"){  req -> Future<[Court]> in
        return Court.query(on: req).all()
    }
    
    let usersController = UsersController()
    
    try router.register(collection: usersController)
    
    let courtController = CourtController()
    
    try router.register(collection: courtController)
        
}

    

