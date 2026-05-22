//
//  Test Objects.swift
//  IOTests
//
//  Created by Steffan Andrews on 2026-05-21.
//

final actor ItemReceiver<T: Sendable> {
    var items: [T] = []
    
    func add(_ item: T) {
        items.append(item)
    }
    
    func reset() {
        items.removeAll()
    }
    
    init() { }
}
