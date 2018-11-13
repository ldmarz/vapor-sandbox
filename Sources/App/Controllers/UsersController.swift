
import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let userRoute = router.grouped(["api", "users"])
        
        userRoute.post(User.self, use: create)
        userRoute.get(use: getAll)
        userRoute.get(User.parameter, use: findById)
        userRoute.get(User.parameter, "acronyms", use: getAcronyms)
        userRoute.put(User.self, at: User.parameter, use: updateUser)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = userRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }
    
    func getAll(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func findById(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func create(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic();
    }
    
    func getAcronyms(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: req).all()
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func updateUser(_ req: Request, newUser: User) throws -> Future<User.Public> {
        return try req.parameters.next(User.self)
            .flatMap { user in
                user.name = newUser.name
                user.username = newUser.username
                user.password = try BCrypt.hash(newUser.password)
                return user.save(on: req).convertToPublic()
        }
    }
    
}
