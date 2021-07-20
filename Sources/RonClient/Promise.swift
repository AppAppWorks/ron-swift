//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 18/7/2021.
//

public final class FailingOnlyPromise {
    var reject: ((Error) -> Void)?
    var rejecting: Error?
}
 
public extension FailingOnlyPromise {
    func `catch`(_ block: @escaping (Error) -> Void) {
        if let rejecting = rejecting {
            block(rejecting)
        } else {
            reject = block
        }
    }
    
    func `catch`(_ block: @escaping (Error) throws -> Void) -> Self {
        let next = Self()
        
        if let rejecting = rejecting {
            do {
                try block(rejecting)
            } catch {
                next.rejecting = error
            }
        } else {
            reject = { [weak self] in
                self?.reject = nil
                do {
                    try block($0)
                } catch {
                    if let reject = next.reject {
                        reject(error)
                    } else {
                        next.rejecting = error
                    }
                }
            }
        }
        
        return next
    }

    func `catch`<T>(_ block: @escaping (Error) throws -> Promise<T>) -> Promise<T> {
        if let rejecting = rejecting {
            do {
                return try block(rejecting)
            } catch {
                return .init { _, reject in
                    reject(error)
                }
            }
        } else {
            return .init { resolve, reject in
                self.reject = { [weak self] in
                    self?.reject = nil
                    do {
                        let p = try block($0)
                        p.then(resolve)
                            .catch(reject)
                    } catch {
                        reject(error)
                    }
                }
            }
            
        }
    }
}

public final class Promise<Value> {
    var resolve: ((Value) -> Void)?
    var reject: ((Error) -> Void)?
    
    var resolving: Value?
    var rejecting: Error?
    
    var isCompleted = false
    
    private init() {}
    
    public init(_ handler: @escaping (@escaping (Value) -> Void,
                               @escaping (Error) -> Void) -> Void) {
        handler({ [self] value in
            guard !isCompleted else { return }
            isCompleted = true
            
            if let resolve = resolve {
                resolve(value)
            } else {
                resolving = value
            }
        }) { [self] error in
            guard !isCompleted else { return }
            isCompleted = true
            
            if let reject = reject {
                reject(error)
            } else {
                rejecting = error
            }
        }
    }
}
 
public extension Promise {
    static func resolve() -> Promise<Void> {
        resolve(())
    }
    
    static func resolve<T>(_ value: T) -> Promise<T> {
        .init { resolve, _ in
            resolve(value)
        }
    }
    
    func then(_ block: @escaping (Value) -> Void) -> FailingOnlyPromise {
        let p = FailingOnlyPromise()
        
        if let resolving = resolving {
            block(resolving)
        } else if let rejecting = rejecting {
            p.rejecting = rejecting
        } else {
            resolve = block
            reject = { [weak self] in
                self?.reject = nil
                p.reject?($0)
            }
        }

        return p
    }
    
    func then(_ block: @escaping (Value) throws -> Void) -> FailingOnlyPromise {
        let p = FailingOnlyPromise()
        
        if let resolving = resolving {
            do {
                try block(resolving)
            } catch {
                p.rejecting = error
            }
        } else if let rejecting = rejecting {
            p.rejecting = rejecting
        } else {
            resolve = { [weak self] in
                self?.reject = nil
                do {
                    try block($0)
                } catch {
                    if let reject = p.reject {
                        reject(error)
                    } else {
                        p.rejecting = error
                    }
                }
            }
            reject = { [weak self] in
                self?.resolve = nil
                p.reject?($0)
            }
        }

        return p
    }
    
    func then<T>(_ block: @escaping (Value) throws -> Promise<T>) -> Promise<T> {
        switch (resolving, rejecting) {
        case let (result?, _):
            do {
                return try block(result)
            } catch {
                return .init { _, reject in
                    reject(error)
                }
            }
        case let (_, error?):
            return .init { _, reject in
                reject(error)
            }
        case _:
            return .init { resolve, reject in
                self.resolve = {
                    do {
                        let p = try block($0)
                        if let resolving = p.resolving {
                            resolve(resolving)
                        } else {
                            p.resolve = resolve
                        }
                        if let rejecting = p.rejecting {
                            reject(rejecting)
                        } else {
                            p.reject = reject
                        }
                    } catch {
                        reject(error)
                    }
                }
                self.reject = reject
            }
        }
    }
    
    func `catch`(_ block: @escaping (Error) -> Void) {
        reject = {
            block($0)
        }
    }
    
    func `catch`<T>(_ block: @escaping (Error) throws -> Promise<T>) -> Promise<T> {
        switch (resolving, rejecting) {
        case (_?, _):
            return .init { _, _ in }
        case let (_, err?):
            do {
                return try block(err)
            } catch {
                return .init { _, reject in
                    reject(error)
                }
            }
        case _:
            return .init { resolve, reject in
                self.reject = {
                    do {
                        let p = try block($0)
                        if let resolving = p.resolving {
                            resolve(resolving)
                        } else {
                            p.resolve = resolve
                        }
                        if let rejecting = p.rejecting {
                            reject(rejecting)
                        } else {
                            p.reject = reject
                        }
                    } catch {
                        reject(error)
                    }
                }
            }
        }
    }
}
