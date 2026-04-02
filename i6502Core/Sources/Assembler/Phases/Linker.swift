import i6502Specification

enum Linker {
    static func process(_ tokens: inout [Token]) throws {
        try resolveLabelReferences(tokens: &tokens)
    }
}

extension Linker {
    fileprivate static func resolveLabelReferences(tokens: inout [Token]) throws {
        let labelKeysWithValues = tokens.compactMap {
            if case let .labelDeclaration(label) = $0 {
                return (label.name, label.address)
            }
            return nil
        }

        if let duplicates = Dictionary(grouping: labelKeysWithValues, by: \.0).first(where: { $1.count > 1 }) {
            throw AssemblerError.linkerError("multiple declarations of label \"\(duplicates.key)\"")
        }

        let labelAddresses: [String: UInt16] = Dictionary(
            uniqueKeysWithValues: labelKeysWithValues
        )

        for (index, token) in tokens.enumerated() {
            if case let .operation(operation) = token {
                switch operation.argument {
                case let .absolute(numberOrUsedLabel),
                     let .absoluteY(numberOrUsedLabel),
                     let .absoluteX(numberOrUsedLabel),
                     let .indirect(numberOrUsedLabel):

                    if case let .label(string) = numberOrUsedLabel {
                        guard let address = labelAddresses[string] else {
                            throw AssemblerError.linkerError("label \"\(string)\" was not resolved")
                        }

                        tokens[index] = .operation(.init(
                            code: operation.code,
                            argument: operation.argument.resolveReference(with: .word(address)),
                            address: operation.address
                        ))
                    }

                case let .relative(.label(string)):
                    guard let targetAddress = labelAddresses[string] else {
                        throw AssemblerError.linkerError("label \"\(string)\" was not resolved")
                    }

                    let distanceValue = Int(targetAddress) - Int(operation.address) - Int(operation.byteLength)
                    if !(-128 ... 127).contains(distanceValue) {
                        throw AssemblerError
                            .linkerError(
                                "label \"\(string)\" declared \(distanceValue) bytes away which is outside the range of a relative branching"
                            )
                    }

                    let distance = UInt8(bitPattern: Int8(distanceValue))

                    tokens[index] = .operation(.init(
                        code: operation.code,
                        argument: .relative(.number(.byte(distance))),
                        address: operation.address
                    ))

                default:
                    break
                }
            }
        }
    }
}

extension Token.Operation.Argument {
    fileprivate func resolveReference(with value: Token.Number) -> Self {
        switch self {
        case .absolute: .absolute(.number(value))
        case .absoluteX: .absoluteX(.number(value))
        case .absoluteY: .absoluteY(.number(value))
        case .indirect: .indirect(.number(value))
        case .relative: .relative(.number(value))
        default: self
        }
    }
}
