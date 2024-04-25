//import XCTest
//
//class ServiceLocatorTests: XCTestCase {
//    /// Tests that a new table instance has zero rows and columns.
//    func testRegisterService() {
//        let locator = AppServiceLocator()
//        let authedUser = AuthedUser()
//        locator.register<User>(instance: authedUser, identifier: nil)
//        let registeredUser = locator.get(identifier: nil)
//        
//        XCTAssertEqual(registeredUser, authedUser, "Registered user was not the same instance as the authed user")
//    }
//}
//
//protocol User {
//    
//}
//
//class AuthedUser: User, Equatable {
//    
//}
//
//ServiceLocatorTests.defaultTestSuite.run()
