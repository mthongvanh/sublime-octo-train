/// # ServiceLocator
/// A type that can register other types which can be retrieved via generic type or identifier
protocol ServiceLocator {
    func register<T: Any>(instance: T, identifier: String?) throws
    func get<T: Any>(serviceType: T.Type, identifier: String?) throws -> T
}

/// # ServiceError
/// Error returned by Service Locators
struct ServiceError: Error {
    enum ErrorKind {
        case duplicateService
        case notFound
        case insufficientParameters
    }
    
    let kind: ErrorKind
}

/// # AppServiceLocator
/// When both an identifier and generic type are supplied, the identifier takes precedence. Only one
/// service may be registered for a type, and only one service can be registered for an identifier.
class AppServiceLocator: ServiceLocator {

    init() {}
    
    fileprivate final var _types: [String: Any.Type] = [:]
    fileprivate final var _services: [String: Any] = [:]
    
    /// Registers a service with the locator
    ///
    /// - parameter instance: instance of the service to register with the locator
    /// - parameter identifier: identifier used to retrieve a service from the locator
    /// - parameter T: type of instance used register with the locator and also used to retrieve the instance of the locator
    /// - returns: None
    ///
    /// - throws: An error is thrown if an instance is already registered for a type or identifier
    ///
    /// # Example #
    /// ```
    /// // Register a
    /// let locator = AppServiceLocator()
    /// register<UsersRepository>(UsersRepositoryImpl());
    /// ```
    public func register<T: Any>(instance: T, identifier: String? = nil) throws {
        let key = getKey(instance, identifier)
        if let value = _services[key] {
            throw ServiceError(kind: .duplicateService)
        } else {
            // update our tables
            _types[key] = T.self
            _services[key] = instance;
        }
    }
    
    func get<T: Any>(serviceType: T.Type, identifier: String? = nil) throws -> T {
        if let id = identifier, _services[id] != nil {
            return _services[id] as! T
        } else {
            for (key, registeredType) in _services {
//                print("registered Type \(registeredType) and serviceType \(T.self)")
                if (registeredType is T) {
//                    print("found the Type!! \(T.self)")
                    return _services[key] as! T
                }
            }
        }
        
        throw ServiceError(kind: .notFound)
    }
    
    private func getKey(_ type: Any, _ identifier: String? = nil) -> String {
        var key: String = ""
        if let id = identifier {
            key = id
        } else {
            key = typeName(service: type)
        }
//        print("derived key \(key)")
        return key;
    }
    
    
    fileprivate func typeName(service: Any) -> String {
        service is Any.Type ? "\(service)" : "\(type(of: service))"
    }
}



protocol User {
    var name: String { get set }
}

class AuthedUser: User, Equatable {
    var name: String = ""
    var authenticated = true
    
    static func == (lhs: AuthedUser, rhs: AuthedUser) -> Bool {
        return lhs.name == rhs.name && lhs.authenticated == rhs.authenticated
    }
}



let locator = AppServiceLocator()

let authedUser = AuthedUser()
authedUser.name = "mike"

// test register a servicen
try locator.register(instance: authedUser)
print("success")

// lookup by exact type
let registeredAuthedUser = try locator.get(serviceType: AuthedUser.self)
print("registered authed user \(registeredAuthedUser)")
//
//let type: Any.Type = User.Type.self
//
//if (registeredAuthedUser is type.Type.self) {
//    print("registered authed user is a user")
//}

// lookup by protocol conformance
let registerdUser: User = try locator.get(serviceType: User.self)
print("registered user \(registerdUser.name)")

// test register sevice with the same type
//try locator.register(instance: authedUser)

//let registeredUser = try locator.get(type: AuthedUser.self, identifier: nil)
//print(registeredUser)
//
//XCTAssertEqual(registeredUser, authedUser, "Registered user was not the same instance as the authed user")
