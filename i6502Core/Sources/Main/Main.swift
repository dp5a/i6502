import Foundation
import i6502Assembler

@main
struct Main {
    static func main() throws {
        guard CommandLine.arguments.count > 1,
              FileManager.default.isReadableFile(atPath: CommandLine.arguments[1]),
              let sourceData = try? Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])),
              let sourceCode = String(data: sourceData, encoding: .utf8)
        else {
            print(CommandLine.arguments)
            return
        }

        let bytecode = try Assembler.compileBytes(input: sourceCode)
        hexDump(bytecode)
    }

    private static func hexDump(_ bytes: [UInt8?]) {
        for (rowIndex, row) in bytes.chunked(into: 16).enumerated() {
            if !row.allSatisfy({ $0 == 0 }) {
                print(String(format: "%.4x: ", rowIndex * 16), terminator: "")
                for col in row {
                    if let col {
                        print(String(format: "%.2x ", col), terminator: "")
                    } else {
                        print("** ", terminator: "")
                    }
                }
                print()
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
