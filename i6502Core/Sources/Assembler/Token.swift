import i6502Specification

// Assembler-to-bytecode intermediate representation
//
// Parsed from assembly by `Tokenizer`, resolved by `Linker`
// and translated to bytes in `Translator`
enum Token: Equatable {
    enum NumberOrUsedLabel: Equatable {
        case number(Token.Number)
        case label(String)
    }

    enum Number: Equatable {
        case byte(UInt8)
        case word(UInt16)
    }

    struct DeclaredLabel: Equatable {
        let name: String
        let address: UInt16
    }

    struct Operation: Equatable {
        enum Argument: Equatable {
            case immediate(UInt8)
            case zeroPage(UInt8)
            case zeroPageX(UInt8)
            case zeroPageY(UInt8)
            case absolute(NumberOrUsedLabel)
            case absoluteX(NumberOrUsedLabel)
            case absoluteY(NumberOrUsedLabel)
            case indirectX(UInt8)
            case indirectY(UInt8)
            case indirect(NumberOrUsedLabel)
            case relative(NumberOrUsedLabel)
            case implied
            case accumulator
        }

        let code: OperationCode
        let argument: Argument
        let address: UInt16

        var byteLength: UInt16 {
            // all op codes take exactly one byte
            // length depends only on addressing mode
            switch argument {
            case .immediate: 2
            case .zeroPage, .zeroPageX, .zeroPageY: 2
            case .indirectX, .indirectY: 2
            case .absolute, .absoluteX, .absoluteY: 3
            case .indirect: 3
            case .relative: 2
            case .implied, .accumulator: 1
            }
        }
    }

    case labelDeclaration(Token.DeclaredLabel)
    case operation(Token.Operation)
    case byte(UInt8)
    case word(UInt16)
    case org(UInt16)
}

extension Token.Operation.Argument {
    func toAddressingMode() -> AddressingMode {
        switch self {
        case .immediate: .immediate
        case .zeroPage: .zeroPage
        case .zeroPageX: .zeroPageX
        case .zeroPageY: .zeroPageY
        case .absolute: .absolute
        case .absoluteX: .absoluteX
        case .absoluteY: .absoluteY
        case .indirectX: .indirectX
        case .indirectY: .indirectY
        case .indirect: .indirect
        case .relative: .relative
        case .implied: .implied
        case .accumulator: .accumulator
        }
    }
}
