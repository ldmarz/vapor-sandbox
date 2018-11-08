import Vapor
struct CategoriesController: RouteCollection {

  func boot(router: Router) throws {

    let categoriesRoute = router.grouped("api", "categories")

    categoriesRoute.post(Category.self, use: create)
    categoriesRoute.get(use: getAll)
    categoriesRoute.get(Category.parameter, use: getById)
}
  func create(_ req: Request, category: Category) throws -> Future<Category> {
    return category.save(on: req)
  }
    
  func getAll(_ req: Request) throws -> Future<[Category]> {
    return Category.query(on: req).all()
  }
    
  func getById(_ req: Request) throws -> Future<Category> {
    return try req.parameters.next(Category.self)
  }
}
