
import Foundation
import i6502Specification

enum Tokenizer {
    static func process(input: String) throws -> [Token] {
        try processTokens(input: input)
    }
}

extension Tokenizer {
    fileprivate static func processTokens(input: String) throws -> [Token] {
        let input: [Character] = Array(input)
        var cursor = Cursor(input: input)
        var currentAddress = 0x0000
        var tokens: [Token] = []
        var defines: [[Character]: Token.Number] = [:]

        input.takeAll(.whitespacesAndNewlines, cursor: &cursor)
        while cursor.globalPosition < input.count {
            if input.takeComment(cursor: &cursor) {
                input.takeAll(.whitespacesAndNewlines, cursor: &cursor)
                continue

            } else if let (_, code) = input.takeOperation(cursor: &cursor) {
                guard currentAddress < 65_536 else {
                    throw AssemblerError.tokenizerError(
                        "\(cursor): address \(String(format: "$%.4x", currentAddress)) is out of bounds"
                    )
                }

                let operation = try input.processOperation(
                    code: code,
                    address: UInt16(currentAddress),
                    defines: defines,
                    cursor: &cursor
                )

                guard Specification.allowedModes[operation.code]?
                    .contains(operation.argument.toAddressingMode()) ?? false
                else {
                    throw AssemblerError.tokenizerError(
                        "\(cursor): \"\(operation.code)\" with \(operation.argument.toAddressingMode()) mode is illegal"
                    )
                }

                tokens.append(.operation(operation))
                currentAddress += Int(operation.byteLength)

            } else if let defineDirective = try input.takeDefineDirective(defines: defines, cursor: &cursor) {
                defines[defineDirective.key] = defineDirective.value

            } else if let orgDirective = try input.takeOrgDirective(defines: defines, cursor: &cursor) {
                tokens.append(.org(orgDirective))
                currentAddress = Int(orgDirective)

            } else if let byteDirective = try input.takeByteDirective(defines: defines, cursor: &cursor) {
                guard currentAddress < 65_536 else {
                    throw AssemblerError.tokenizerError(
                        "\(cursor): address \(String(format: "$%.4x", currentAddress)) is out of bounds"
                    )
                }

                tokens.append(.byte(byteDirective))
                currentAddress += 1

            } else if let wordDirective = try input.takeWordDirective(defines: defines, cursor: &cursor) {
                guard currentAddress < 65_535 else {
                    throw AssemblerError.tokenizerError(
                        "\(cursor): address \(String(format: "$%.4x", currentAddress)) is out of bounds"
                    )
                }

                tokens.append(.word(wordDirective))
                currentAddress += 2

            } else {
                let labelDeclaration = try input.processLabelDeclaration(
                    address: UInt16(currentAddress),
                    cursor: &cursor
                )
                tokens.append(.labelDeclaration(labelDeclaration))
            }

            input.takeAll(.whitespacesAndNewlines, cursor: &cursor)
        }
        return tokens
    }
}

extension [Character] {
    fileprivate func processOperation(
        code: OperationCode,
        address: UInt16,
        defines: [[Character]: Token.Number],
        cursor: inout Cursor
    ) throws -> Token.Operation {
        takeAll(.whitespacesAndNewlines, cursor: &cursor)

        // try immediate operations
        if take("#", cursor: &cursor) == "#" {
            guard let value = try takeNumberOrDefine(defines: defines, cursor: &cursor) else {
                throw AssemblerError.tokenizerError("\(cursor): expected a number or predefined constant")
            }
            guard case let .byte(byteValue) = value else {
                throw AssemblerError.tokenizerError("\(cursor): only byte values allowed in immediate mode")
            }
            return .init(code: code, argument: .immediate(byteValue), address: address)
        }

        // try indirect operations
        if take("(", cursor: &cursor) == "(" {
            takeAll(.whitespacesAndNewlines, cursor: &cursor)

            if let tryNumber = try? takeNumberOrDefine(defines: defines, cursor: &cursor) {
                switch tryNumber {
                case let .byte(value):
                    if take(")", cursor: &cursor) == ")" {
                        takeAll(.whitespacesAndNewlines, cursor: &cursor)
                        guard !take(",", cursor: &cursor).isEmpty else {
                            throw AssemblerError.tokenizerError(
                                "\(cursor): expected indirect,Y addressing mode for byte value"
                            )
                        }
                        takeAll(.whitespacesAndNewlines, cursor: &cursor)
                        guard !take("y", cursor: &cursor).isEmpty else {
                            throw AssemblerError.tokenizerError(
                                "\(cursor): expected indirect,Y addressing mode for byte value"
                            )
                        }
                        return .init(code: code, argument: .indirectY(value), address: address)
                    }
                    if take(",", cursor: &cursor) == "," {
                        takeAll(.whitespacesAndNewlines, cursor: &cursor)
                        guard !take("x", cursor: &cursor).isEmpty else {
                            throw AssemblerError.tokenizerError(
                                "\(cursor): expected indirect,X addressing mode for byte value"
                            )
                        }
                        takeAll(.whitespacesAndNewlines, cursor: &cursor)
                        guard !take(")", cursor: &cursor).isEmpty else {
                            throw AssemblerError.tokenizerError(
                                "\(cursor): expected indirect,X addressing mode for byte value"
                            )
                        }
                        return .init(code: code, argument: .indirectX(value), address: address)
                    }
                    throw AssemblerError.tokenizerError("\(cursor): expected indirect X or Y addressing modes")

                case .word:
                    guard take(")", cursor: &cursor) == ")" else {
                        throw AssemblerError.tokenizerError(
                            "\(cursor): expected indirect addressing mode for word value"
                        )
                    }
                    return .init(code: code, argument: .indirect(.number(tryNumber)), address: address)
                }
            }

            guard let label = try? takeName(cursor: &cursor) else {
                throw AssemblerError.tokenizerError("\(cursor): expected constant or label for indirect operation")
            }
            guard take(")", cursor: &cursor) == ")" else {
                throw AssemblerError.tokenizerError("\(cursor): expected ')' after indirect label")
            }
            return .init(code: code, argument: .indirect(.label(String(label))), address: address)
        }

        // probe next token
        var probingCursor = cursor
        if let numberOrLabel = try? processNumberOrLabel(defines: defines, cursor: &probingCursor) {
            // next token is label declaration - current op has no arguments
            if case .label = numberOrLabel, take(":", cursor: &probingCursor) == ":" {
                if Specification.accumulatorOperations.contains(code) {
                    return .init(code: code, argument: .accumulator, address: address)
                }
                return .init(code: code, argument: .implied, address: address)
            }
            // next token is operation - current op has no arguments
            if case let .label(opCode) = numberOrLabel,
               OperationCode.allCases.map(\.rawValue).contains(String(opCode))
            {
                if Specification.accumulatorOperations.contains(code) {
                    return .init(code: code, argument: .accumulator, address: address)
                }
                return .init(code: code, argument: .implied, address: address)
            }
            cursor = probingCursor

            if case .label("a") = numberOrLabel {
                return .init(code: code, argument: .accumulator, address: address)
            }

            if take(",", cursor: &cursor) == "," {
                takeAll(.whitespacesAndNewlines, cursor: &cursor)
                if take("x", cursor: &cursor) == "x" {
                    return switch numberOrLabel {
                    case .label, .number(.word):
                        .init(code: code, argument: .absoluteX(numberOrLabel), address: address)
                    case let .number(.byte(value)):
                        .init(code: code, argument: .zeroPageX(value), address: address)
                    }
                }
                if take("y", cursor: &cursor) == "y" {
                    return switch numberOrLabel {
                    case .label, .number(.word):
                        .init(code: code, argument: .absoluteY(numberOrLabel), address: address)
                    case let .number(.byte(value)):
                        .init(code: code, argument: .zeroPageY(value), address: address)
                    }
                }
                throw AssemblerError.tokenizerError("\(cursor): expected X or Y absolute/zero-page modes")
            }

            return switch numberOrLabel {
            case let .label(value):
                if Specification.branchingOperations.contains(code) {
                    .init(code: code, argument: .relative(.label(value)), address: address)
                } else {
                    .init(code: code, argument: .absolute(numberOrLabel), address: address)
                }
            case .number(.word):
                .init(code: code, argument: .absolute(numberOrLabel), address: address)
            case let .number(.byte(value)):
                .init(code: code, argument: .zeroPage(value), address: address)
            }
        }

        // we've tried everything - default to implied addressing mode
        if Specification.accumulatorOperations.contains(code) {
            return .init(code: code, argument: .accumulator, address: address)
        }
        return .init(code: code, argument: .implied, address: address)
    }

    private func processNumberOrLabel(
        defines: [[Character]: Token.Number],
        cursor: inout Cursor
    ) throws -> Token.NumberOrUsedLabel {
        if let tryNumber = try? takeNumber(cursor: &cursor),
           let value = try tryNumber.parseNumber()
        {
            return .number(value)
        }

        if let tryName = try? takeName(cursor: &cursor) {
            if let resolvedValue = defines[tryName] {
                return .number(resolvedValue)
            }
            return .label(String(tryName))
        }
        throw AssemblerError.tokenizerError("\(cursor): expected number or label")
    }

    fileprivate func processLabelDeclaration(
        address: UInt16,
        cursor: inout Cursor
    ) throws -> Token.DeclaredLabel {
        let name = try takeName(cursor: &cursor)
        guard !name.isEmpty, take(":", cursor: &cursor) == ":" else {
            if !name.isEmpty {
                throw AssemblerError.tokenizerError("\(cursor): unrecognized token \"\(String(name))\"")
            }
            throw AssemblerError.tokenizerError("\(cursor): unexpected EOF")
        }
        return Token.DeclaredLabel(name: String(name), address: address)
    }

}

extension [Character] {
    private func takeNumberOrDefine(
        defines: [[Character]: Token.Number],
        cursor: inout Cursor
    ) throws -> Token.Number? {
        var copyCursor = cursor
        if let constantNumber = try? takeNumber(cursor: &copyCursor) {
            guard let parsedValue = try constantNumber.parseNumber() else {
                throw AssemblerError
                    .tokenizerError("\(copyCursor): expected a number, found \"\(String(constantNumber))\"")
            }
            cursor = copyCursor
            return parsedValue
        }
        if let name = try? takeName(cursor: &copyCursor) {
            guard let resolvedNumber = defines[name] else {
                throw AssemblerError.tokenizerError("\(copyCursor): unrecognized constant \"\(String(name))\"")
            }
            cursor = copyCursor
            return resolvedNumber
        }
        return nil
    }

    fileprivate func takeOperation(cursor: inout Cursor) -> ([Character], OperationCode)? {
        var cursorCopy = cursor

        let token = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)
        guard let code = OperationCode(rawValue: token.map { $0.lowercased() }.joined(separator: "")) else {
            return nil
        }
        cursor = cursorCopy
        return (token, code)
    }

    fileprivate func takeComment(cursor: inout Cursor) -> Bool {
        var cursorCopy = cursor

        if take(";", cursor: &cursorCopy) == ";" {
            takeUntil(.newlines, cursor: &cursorCopy)
            take(.newlines, cursor: &cursorCopy)
            cursor = cursorCopy
            return true
        }
        return false
    }

    private static let reservedNames = Set(OperationCode.allCases.map(\.rawValue))
        .union(["a", "x", "y", "org", "byte", "word", "define"])

    fileprivate func takeDefineDirective(
        defines: [[Character]: Token.Number],
        cursor: inout Cursor
    ) throws -> (key: [Character], value: Token.Number)? {

        var cursorCopy = cursor

        let nextToken = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)
        if nextToken == Array(".define") {
            takeAll(.whitespacesAndNewlines, cursor: &cursorCopy)
            let key = try takeName(cursor: &cursorCopy)
            guard defines[key] == nil else {
                throw AssemblerError.tokenizerError("\(cursorCopy): invalid redefenition of \"\(String(key))\"")
            }
            guard !Self.reservedNames.contains(String(key)) else {
                throw AssemblerError.tokenizerError("\(cursorCopy): \"\(String(key))\" is reserved from definition")
            }

            takeAll(.whitespacesAndNewlines, cursor: &cursorCopy)
            let number = try takeNumber(cursor: &cursorCopy)
            guard let value = try number.parseNumber() else {
                throw AssemblerError.tokenizerError("\(cursorCopy): only numbers are allowed as define values")
            }

            cursor = cursorCopy
            return (key: key, value: value)
        }
        return nil
    }

    fileprivate func takeOrgDirective(defines: [[Character]: Token.Number], cursor: inout Cursor) throws -> UInt16? {
        var cursorCopy = cursor

        let nextToken = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)
        if nextToken == Array(".org") {
            takeAll(.whitespacesAndNewlines, cursor: &cursorCopy)
            let argument = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)

            if case let .word(resolvedValue) = defines[argument] {
                cursor = cursorCopy
                return resolvedValue
            }

            guard case let .word(value) = try argument.parseNumber() else {
                throw AssemblerError.tokenizerError("\(cursorCopy): expected a word literal after \".org\"")
            }
            cursor = cursorCopy
            return value
        }
        return nil
    }

    fileprivate func takeByteDirective(defines: [[Character]: Token.Number], cursor: inout Cursor) throws -> UInt8? {
        var cursorCopy = cursor

        let nextToken = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)
        if nextToken == Array(".byte") {
            takeAll(.whitespacesAndNewlines, cursor: &cursorCopy)
            let argument = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)

            if case let .byte(resolvedValue) = defines[argument] {
                cursor = cursorCopy
                return resolvedValue
            }

            guard case let .byte(value) = try argument.parseNumber() else {
                throw AssemblerError.tokenizerError("\(cursorCopy): expected a byte literal after \".byte\"")
            }
            cursor = cursorCopy
            return value
        }
        return nil
    }

    fileprivate func takeWordDirective(defines: [[Character]: Token.Number], cursor: inout Cursor) throws -> UInt16? {
        var cursorCopy = cursor

        let nextToken = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)
        if nextToken == Array(".word") {
            takeAll(.whitespacesAndNewlines, cursor: &cursorCopy)
            let argument = takeUntil(.whitespacesAndNewlines, cursor: &cursorCopy)

            if case let .word(resolvedValue) = defines[argument] {
                cursor = cursorCopy
                return resolvedValue
            }

            guard case let .word(value) = try argument.parseNumber() else {
                throw AssemblerError.tokenizerError("\(cursorCopy): expected a word literal after \".word\"")
            }
            cursor = cursorCopy
            return value
        }
        return nil
    }
}

extension [Character] {
    // allowed:
    //   - hexadecimal: byte ($00..$FF) or word ($0000..$FFFF)
    //   - decimal: -128..255 (converts to uint8) or 256..65535 (converts to uint16)
    func parseNumber() throws -> Token.Number? {
        let isHexidecimal = first == "$"
        guard let value = Int(isHexidecimal ? String(dropFirst()) : String(self), radix: isHexidecimal ? 16 : 10) else {
            return nil
        }

        if isHexidecimal {
            guard value < 65_536 else {
                throw AssemblerError.tokenizerError("number is outside of word ($0000..$FFFF) range")
            }

            return count <= 3 ? .byte(UInt8(value)) : .word(UInt16(value))
        }
        if -128 ..< 256 ~= value {
            return .byte(UInt8(value < 0 ? 0x100 + value : value))
        }
        if 256 ..< 65_536 ~= value {
            return .word(UInt16(value))
        }
        throw AssemblerError.tokenizerError("number is outside allowed range")
    }
}
