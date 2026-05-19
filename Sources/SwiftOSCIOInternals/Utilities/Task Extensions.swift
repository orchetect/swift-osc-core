//
//  Task Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Dispatch

extension Task {
    /// Executes the given async closure synchronously, waiting for it to finish before returning.
    ///
    /// Borrowed from https://wadetregaskis.com/calling-swift-concurrency-async-code-synchronously-in-swift/
    ///
    /// > Warning:
    /// >
    /// > Do not call this from a thread used by Swift Concurrency (e.g. an actor, including global actors like MainActor)
    /// > if the closure - or anything it calls transitively via `await` - might be bound to that same isolation context.
    /// > Doing so may result in deadlock.
    static func sync(_ code: sending () async throws(Failure) -> Success) throws(Failure) -> Success {
        let semaphore = DispatchSemaphore(value: 0)
        
        nonisolated(unsafe) var result: Result<Success, Failure>! = nil
        
        withoutActuallyEscaping(code) {
            nonisolated(unsafe) let sendableCode = $0
            
            let coreTask = Task<Void, Never>.detached(priority: .userInitiated) { @Sendable () async -> Void in
                do {
                    result = .success(try await sendableCode())
                } catch {
                    result = .failure(error as! Failure)
                }
            }
            
            Task<Void, Never>.detached(priority: .userInitiated) {
                await coreTask.value
                semaphore.signal()
            }
            
            semaphore.wait()
        }
        
        return try result.get()
    }
}
