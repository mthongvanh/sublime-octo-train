import cleanboot_iOS

/// # AppServiceLocator
/// When both an identifier and generic type are supplied, the identifier takes precedence. Only one
/// service may be registered for a type, and only one service can be registered for an identifier.
public class AppServiceLocator: ServiceLocator {
    
    /// Generally there will only be one instance of the app service locator, but
    /// call this initializer to create separate service locator instances that
    /// do not share any state with the singleton instance
    init() {
    }
    
    /// Singleton instance of the AppServiceLocator()
    static let shared = AppServiceLocator()
    
    fileprivate final var _types: [String: Any.Type] = [:]
    fileprivate final var _services: [String: Any] = [:]
    //    fileprivate final var _factories: [String: Any] = [:]
    
    /// Registers a service with the locator
    ///
    /// - parameter instance: instance of the service to register with the locator
    /// - parameter identifier: identifier used to retrieve a service from the locator
    /// - returns: None
    ///
    /// - throws: An error is thrown if an instance is already registered for a type or identifier
    ///
    /// # Example #
    /// ```
    /// // Register a
    /// let locator = AppServiceLocator()
    /// locator.register(instance: UsersRepositoryImpl());
    /// ```
    public func registerSingleton<T>(instance: T, identifier: String?) throws {
        try register(service: instance, type: T.self, identifier: identifier)
    }
    
    public func registerLazySingleton<T>(
        instantiator: @escaping () -> T,
        type: T.Type,
        identifier: String?
    ) throws {
        try register(service: instantiator, type: type, identifier: identifier)
    }
    
    
    public func registerFactory<T>(
        instantiator: @escaping FactoryConstructor<T>,
        type: T.Type,
        identifier: String?
    ) throws {
        try register(service: instantiator, type: type, identifier: identifier)
    }
    
    fileprivate func register<T>(
        service: Any,
        type: T.Type,
        identifier: String?
    ) throws {
            let key = getKey(type, identifier)
            if _services[key] != nil {
                throw ServiceError(kind: .duplicateService)
            } else {
                // update our tables
                _types[key] = T.self
                _services[key] = service;
            }
    }
    
    public func get<T>(
        serviceType: T.Type,
        identifier: String? = nil,
        parameters: FactoryParameters? = (nil, nil)
    ) throws -> T {
        if let id = identifier, _services[id] != nil {
            return _services[id] as! T
        } else {
            for (key, registeredType) in _services {
                //                print("registered Type \(registeredType) and serviceType \(T.self)")
                if (registeredType is T) {
                    //                    print("found the Type!! \(T.self)")
                    return _services[key] as! T
                } // must be a lazy singleton
                else if (registeredType is () -> T) {
                    let instance = (registeredType as! () -> T)()
                    // make sure to update our services collection by replacing the constructor with
                    // the newly created singleton instance
                    _services.updateValue(instance, forKey: key)
                    return instance
                } // must be a factory
                else if (registeredType is FactoryConstructor<T>) {
                    let instance = try (registeredType as! FactoryConstructor<T>)(parameters)
                    return instance
                } else {
//                    debugPrint("registered type \(registeredType) with target -- identifier \(identifier ?? "(empty identifier)") -- serviceType \(serviceType)")
                }
            }
        }
        
        throw ServiceError(kind: .notFound)
    }
    
    fileprivate func getKey(_ type: Any, _ identifier: String? = nil) -> String {
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
