
import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let userRoute = router.grouped(["api", "users"])
        
        userRoute.post(User.self, use: create)
        userRoute.get(use: getAll)
        userRoute.get(User.parameter, use: getAll)
        userRoute.get(User.parameter, "acronyms", use: getAcronyms)
    }
    
    func getAll(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all();
    }
    
    func findById(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func create(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req);
    }
    
    func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: req).all()
        }
    }
}
