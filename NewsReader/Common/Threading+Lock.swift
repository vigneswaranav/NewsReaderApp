//
//  Threading+Lock.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

protocol Lock: AtomicRWScopeProvider {
    /// Acquires a lock. It is recommended to use the perform method where possible to limit scope for errors.
    func lock()
    /// Releases a previously aquired lock.
    func unlock()
    /// Performs block in a locked scope.
    func perform<T: Any>(_ block: () -> T) -> T
}

enum AtomicRWScopeProviderType {
    /// Optimized for higher amount of reads than writes. Concurrent reads, serial writes.
    case dispatchQueue
    /// Optimized for balanced reads and writes. Provides better performance compared to `pThreadRWLock` if writes are balanced with reads.
    case osUnfairLock
    /// Optimized for higher amount of reads than writes. Concurrent reads, serial writes. Provides better  performance compared to `dispatchQueue`, lower overhead.
    case pThreadRWLock
    case nsLock
    case recursiveNSLock
    
    static var `default`: AtomicRWScopeProviderType {
        return .pThreadRWLock
    }
    
    static func defaultCreate() -> AtomicRWScopeProvider {
        return AtomicRWScopeProviderType.default.create()
    }
    
    func create() -> AtomicRWScopeProvider {
        switch self {
        case .dispatchQueue:
            return DispatchQueueAtomicRWScopeProvider()
        case .osUnfairLock:
            return AROSUnfairLock()
        case .pThreadRWLock:
            return ARPThreadRWLock()
        case .nsLock:
            return NSLock()
        case .recursiveNSLock:
            return NSRecursiveLock()
        }
    }
    
}

protocol AtomicRWScopeProvider {
    func performRead<T: Any>(_ block: () -> T) -> T
    func performWrite(_ block: @escaping () -> Void)
}

extension Lock {
    func perform<T: Any>(_ block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
    
    /// Perform state read work in locked scope.
    func performRead<T: Any>(_ block: () -> T) -> T {
        perform(block)
    }
    
    /// Perform state write work in locked scope.
    func performWrite(_ block: @escaping () -> Void) {
        perform(block)
    }
}

extension NSLock: Lock { /* protocol conformance */ }
extension NSRecursiveLock: Lock { /* protocol conformance */ }

final class DispatchQueueAtomicRWScopeProvider: AtomicRWScopeProvider {
    
    private  let queue = DispatchQueue(label: "com.arattai.thread-safe.rw",
                                       attributes: .concurrent)
    
    func performRead<T>(_ block: () -> T) -> T {
        queue.sync {
            return block()
        }
    }
    
    func performWrite(_ block: @escaping () -> Void) {
        queue.async(flags: .barrier) {
            block()
        }
    }
    
}

final class AROSUnfairLock: Lock {
    
    private let lockPointer: UnsafeMutablePointer<os_unfair_lock_s> = {
        let block =  UnsafeMutablePointer<os_unfair_lock_s>.allocate(capacity: 1)
        block.initialize(to: os_unfair_lock_s())
        return block
    }()
    
    func lock() {
        os_unfair_lock_lock(lockPointer)
    }
    
    func unlock() {
        os_unfair_lock_unlock(lockPointer)
    }
    
    deinit {
        lockPointer.deinitialize(count: 1)
        lockPointer.deallocate()
    }
    
}

final class ARPThreadRWLock: Lock {
    
    private let lockPointer: UnsafeMutablePointer<pthread_rwlock_t> = {
        let lock = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        lock.initialize(to: pthread_rwlock_t())
        pthread_rwlock_init(lock, nil)
        return lock
    }()
    
    func writeLock() {
        pthread_rwlock_wrlock(lockPointer)
    }
    
    func readLock() {
        pthread_rwlock_rdlock(lockPointer)
    }
    
    func lock() {
        writeLock()
    }
    
    func unlock() {
        pthread_rwlock_unlock(lockPointer)
    }
    
    func performRead<T: Any>(_ block: () -> T) -> T {
        readLock()
        let value = block()
        unlock()
        return value
    }
    
    func performWrite(_ block: @escaping () -> Void) {
        writeLock()
        block()
        unlock()
    }
    
    deinit {
        pthread_rwlock_destroy(lockPointer)
        lockPointer.deinitialize(count: 1)
        lockPointer.deallocate()
    }
    
}
