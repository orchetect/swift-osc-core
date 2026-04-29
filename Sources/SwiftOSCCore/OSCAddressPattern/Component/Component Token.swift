//
//  Component Token.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension OSCAddressPattern.Component {
    enum Token {
        /// One or more sequential literal characters.
        case literal(String)

        /// `*`
        case zeroOrMoreWildcard

        /// `?`
        case singleCharWildcard

        /// `[]` bracket expression.
        case singleChar(isExclusion: Bool, groups: Set<CharacterGroup>)

        /// `{}` curly-brace expression.
        case strings(strings: Set<String>)
    }
}

extension OSCAddressPattern.Component.Token: Equatable { }

extension OSCAddressPattern.Component.Token: Hashable { }

extension OSCAddressPattern.Component.Token: Sendable { }

extension OSCAddressPattern.Component.Token {
    enum CharacterGroup: Equatable, Hashable {
        /// Single character.
        case single(Character)

        /// Contiguous range of ASCII characters.
        case asciiRange(start: Character, end: Character)
    }
}
