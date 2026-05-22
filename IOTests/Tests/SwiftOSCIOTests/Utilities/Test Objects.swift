//
//  Test Objects.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
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
