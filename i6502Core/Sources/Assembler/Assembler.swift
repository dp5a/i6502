import Foundation

public enum Assembler {
    public static func compileBytes(input: String) throws -> [UInt8?] {
        var tokens = try Tokenizer.process(input: input.lowercased())
        try Linker.process(&tokens)
        return try Translator.process(tokens)
    }

    public static func compileData(input: String) throws -> Data {
        try Data(compileBytes(input: input).map { $0 ?? 0 })
    }
}

public enum AssemblerError: Error, Equatable {
    case tokenizerError(String)
    case linkerError(String)
    case translatorError(String)
}
