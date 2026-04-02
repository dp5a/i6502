import i6502Specification

enum Translator {
    static func process(_ tokens: [Token]) throws -> [UInt8?] {
        try translateBytecode(tokens: tokens)
    }
}

extension Translator {
    fileprivate static func translateBytecode(tokens: [Token]) throws -> [UInt8?] {
        var currentAddress: UInt16 = 0x0000
        var memory = [UInt8?](repeating: nil, count: 65_536)

        for token in tokens {
            switch token {
            case .labelDeclaration:
                break

            case let .byte(byteValue):
                memory[currentAddress] = byteValue
                currentAddress += 1

            case let .org(address):
                currentAddress = address

            case let .operation(operation):
                let specOperation = i6502Specification.Operation(operation.code, operation.argument.toAddressingMode())
                guard let translatedOp = Specification.translate(op: specOperation) else {
                    throw AssemblerError.translatorError(
                        "\(specOperation.symbol) in \(specOperation.mode) mode is illegal, use \".byte **\" if you are absolutely sure"
                    )
                }

                memory[currentAddress] = translatedOp
                currentAddress += 1
                for item in try operation.argument.value() {
                    memory[currentAddress] = item
                    currentAddress += 1
                }
            }
        }
        return memory
    }
}

extension Token.Operation.Argument {
    fileprivate func value() throws -> [UInt8] {
        switch self {
        case let .immediate(value): [value]
        case let .zeroPage(value): [value]
        case let .zeroPageX(value): [value]
        case let .zeroPageY(value): [value]
        case let .absolute(.number(number)): number.toBytecode()
        case let .absoluteX(.number(number)): number.toBytecode()
        case let .absoluteY(.number(number)): number.toBytecode()
        case let .relative(.number(number)): number.toBytecode()
        case let .indirectX(value): [value]
        case let .indirectY(value): [value]
        case let .indirect(.number(number)): number.toBytecode()
        case .implied: []
        case .accumulator: []
        case let .absolute(.label(label)),
             let .absoluteX(.label(label)),
             let .absoluteY(.label(label)),
             let .indirect(.label(label)),
             let .relative(.label(label)):
            throw AssemblerError
                .translatorError("unresolved label \"\(label)\" reference in \(toAddressingMode()) mode")
        }
    }
}

extension Token.Number {
    fileprivate func toBytecode() -> [UInt8] {
        switch self {
        case let .byte(value): [value]
        case let .word(value): [UInt8(value & 0x00FF), UInt8((value & 0xFF00) >> 8)]
        }
    }
}

extension Array {
    fileprivate subscript(_ index: UInt16) -> Element {
        get {
            self[Int(index)]
        }
        set(newValue) {
            self[Int(index)] = newValue
        }
    }
}
