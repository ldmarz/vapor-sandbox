import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        /* Path to use this methods */
        let acronymsRoutes = router.grouped("api", "acronym")
        
        /* List of availables methods */
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getAcronymById)
        acronymsRoutes.get("search", use: findAcronym)
        acronymsRoutes.get(Acronym.parameter, "user", use: getWithUser)
        acronymsRoutes.delete(Acronym.parameter, use: deleteAcronym)
        acronymsRoutes.post(Acronym.self, use: saveAcronym)
        acronymsRoutes.put(Acronym.self, at: Acronym.parameter, use: updateAcronym)
        acronymsRoutes.post(Acronym.parameter, "categories", Category.parameter, use: addCategories)

    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all();
    }
    
    func getAcronymById(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func saveAcronym(_ req: Request, newAcronym: Acronym) throws -> Future<Acronym> {
        return newAcronym.save(on: req)
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
                acronym.userID = newAcronym.userID
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
}
