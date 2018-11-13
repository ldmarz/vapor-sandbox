import Vapor
import Fluent
import Authentication

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        /* Path to use this methods */
        let acronymsRoutes = router.grouped("api", "acronym")
        
        /* List of availables methods */
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getAcronymById)
        acronymsRoutes.get("search", use: findAcronym)
        acronymsRoutes.get(Acronym.parameter, "user", use: getWithUser)
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategories)
        
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware
        )

        tokenAuthGroup.post(AcronymCreateData.self, use: saveAcronym)
        tokenAuthGroup.delete(Acronym.parameter, use: deleteAcronym)
        tokenAuthGroup.put(Acronym.self, at: Acronym.parameter, use: updateAcronym)
        tokenAuthGroup.post(Acronym.parameter, "categories", Category.parameter, use: addCategories)
        tokenAuthGroup.delete(Acronym.parameter, "categories", Category.parameter, use: removeCategories)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all();
    }
    
    func getAcronymById(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func saveAcronym(_ req: Request, newAcronym: AcronymCreateData) throws -> Future<Acronym> {
        let user = try req.requireAuthenticated(User.self)
        
        let acronym = try Acronym(
            short: newAcronym.short,
            long: newAcronym.long,
            userID: user.requireID()
        )

        return acronym.save(on: req)
    }
    
    func deleteAcronym(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.ok)
    }
    
    func updateAcronym(_ req: Request, newAcronym: Acronym) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
            .flatMap { acronym in
                acronym.short = newAcronym.short
                acronym.long = newAcronym.long
                
                let user = try req.requireAuthenticated(User.self)
                acronym.userID = try user.requireID()
                return acronym.save(on: req)
        }
    }
    
    func findAcronym(_ req: Request) throws -> Future<[Acronym]> {
        guard
            let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req)
            .group(.or) { or in
                or.filter(\.short == searchTerm)
                or.filter(\.long == searchTerm)
            }
            .all()
        
    }
    
    func getWithUser(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                acronym.user.get(on: req);
        }
    }
    
    func addCategories(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)
        )  { acronym, category in
                acronym.categories
                    .attach(category, on: req)
                    .transform(to: .created)
        }
    }
    
    func getCategories(_ req: Request) throws -> Future<[Category]> {
        return try  req.parameters.next(Acronym.self)
            .flatMap(to: [Category].self) { acronym in
                try acronym.categories.query(on: req).all()
        }
    }
    
    func removeCategories(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)
        ) { acronym, category in
            acronym.categories
                .detach(category, on: req)
                .transform(to: .ok)
        }
    }
}

struct AcronymCreateData: Content {
    let short: String
    let long: String
}
