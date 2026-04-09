import Testing
import i6502Specification
@testable import i6502Assembler

@Suite
struct LinkerTests {
    @Test("test empty tokens")
    func empty() {
        #expect(throws: Never.self, "resolved empty tokens without issues") {
            let initialTokens: [Token] = []
            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(initialTokens == processedTokens, "resolving preserved empty tokens")
        }
    }

    @Test("test basic label declaration")
    func basicLabelDeclaration() {
        #expect(throws: Never.self, "resolved tokens without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000))
            ]
            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(initialTokens == processedTokens, "resolving preserved original token")
        }
    }

    @Test("test basic tokens")
    func basicTokens() {
        #expect(throws: Never.self, "resolved tokens without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .byte(0x0000),
                .org(0x1000),
                .operation(.init(code: .nop, argument: .implied, address: 0x1000))
            ]
            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(initialTokens == processedTokens, "resolving preserved original token")
        }
    }

    @Test("test forward resolving")
    func forwardResolve() {
        #expect(throws: Never.self, "resolved absolute labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0000)),
                .operation(.init(code: .jmp, argument: .absolute(.label("start")), address: 0x0001))
            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0000)),
                .operation(.init(code: .jmp, argument: .absolute(.number(.word(0x0000))), address: 0x0001))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"start\" label to $0000, rest unchanged")
        }
        #expect(throws: Never.self, "resolved relative labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0000)),
                .operation(.init(code: .bne, argument: .relative(.label("start")), address: 0x0001))
            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0000)),
                .operation(.init(code: .bne, argument: .relative(.number(.byte(0xFD))), address: 0x0001))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"start\" label to $FD, rest unchanged")
        }
    }

    @Test("test backward resolving")
    func backwardResolve() {
        #expect(throws: Never.self, "resolved absolute labels without issues") {
            let initialTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .absolute(.label("end")), address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0003)),
                .labelDeclaration(.init(name: "end", address: 0x0004))
            ]
            let expectedTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .absolute(.number(.word(0x0004))), address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0003)),
                .labelDeclaration(.init(name: "end", address: 0x0004))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"end\" label to $0004, rest unchanged")
        }
        #expect(throws: Never.self, "resolved relative labels without issues") {
            let initialTokens: [Token] = [
                .operation(.init(code: .beq, argument: .relative(.label("end")), address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0002)),
                .labelDeclaration(.init(name: "end", address: 0x0003))
            ]
            let expectedTokens: [Token] = [
                .operation(.init(code: .beq, argument: .relative(.number(.byte(0x01))), address: 0x0000)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0002)),
                .labelDeclaration(.init(name: "end", address: 0x0003))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"end\" label to $01, rest unchanged")
        }
    }

    @Test("test self resolving")
    func selfResolve() {
        #expect(throws: Never.self, "resolved absolute labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .jmp, argument: .absolute(.label("start")), address: 0x0000))
            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .jmp, argument: .absolute(.number(.word(0x0000))), address: 0x0000))
            ]
            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"start\" label to $0000, rest unchanged")
        }
        #expect(throws: Never.self, "resolved relative labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .bcc, argument: .relative(.label("start")), address: 0x0000))
            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .bcc, argument: .relative(.number(.byte(0xFE))), address: 0x0000))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved \"start\" label to $FE, rest unchanged")
        }
    }

    @Test("multiple resolving")
    func multipleResolve() {
        #expect(throws: Never.self, "resolved relative labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .bcc, argument: .relative(.label("start")), address: 0x0000)),
                .operation(.init(code: .beq, argument: .relative(.label("end")), address: 0x0002)),
                .labelDeclaration(.init(name: "end", address: 0x0004))

            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0x0000)),
                .operation(.init(code: .bcc, argument: .relative(.number(.byte(0xFE))), address: 0x0000)),
                .operation(.init(code: .beq, argument: .relative(.number(.byte(0x00))), address: 0x0002)),
                .labelDeclaration(.init(name: "end", address: 0x0004))
            ]

            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved multiple references successfully")
        }
    }

    @Test("indirect resolving")
    func indirectResolve() {
        #expect(throws: Never.self, "resolved indirect labels without issues") {
            let initialTokens: [Token] = [
                .labelDeclaration(.init(name: "reference", address: 0x0000)),
                .byte(0x34),
                .byte(0x12),
                .operation(.init(code: .jmp, argument: .indirect(.label("reference")), address: 0x0002))

            ]
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "reference", address: 0x0000)),
                .byte(0x34),
                .byte(0x12),
                .operation(.init(code: .jmp, argument: .indirect(.number(.word(0x0000))), address: 0x0002))
            ]
            var processedTokens = initialTokens
            try Linker.process(&processedTokens)
            #expect(expectedTokens == processedTokens, "resolved multiple references successfully")
        }
    }

    @Test("failing label multiple declaration")
    func failingRedeclaration() {
        #expect(throws: AssemblerError.linkerError("multiple declarations of label \"end\"")) {
            var tokens: [Token] = [
                .labelDeclaration(.init(name: "end", address: 0x0000)),
                .labelDeclaration(.init(name: "end", address: 0x0001))
            ]
            try Linker.process(&tokens)
        }
    }

    @Test("failing unknown declaration")
    func failingUnknownDeclaration() {
        #expect(throws: AssemblerError.linkerError("label \"end\" was not resolved")) {
            var tokens: [Token] = [
                .operation(.init(code: .jmp, argument: .absolute(.label("end")), address: 0x0000))
            ]
            try Linker.process(&tokens)
        }
        #expect(throws: AssemblerError.linkerError("label \"end\" was not resolved")) {
            var tokens: [Token] = [
                .operation(.init(code: .bcc, argument: .relative(.label("end")), address: 0x0000))
            ]
            try Linker.process(&tokens)
        }
    }

    @Test("failing forward branching declaration out of reach")
    func failingForwardOutOfReach() {
        #expect(
            throws: AssemblerError
                .linkerError(
                    "label \"start\" declared -129 bytes away which is outside the range of a relative branching"
                )
        ) {
            var tokens: [Token] = [
                .labelDeclaration(.init(name: "start", address: 0)),
                .operation(.init(code: .bpl, argument: .relative(.label("start")), address: 127))
            ]
            try Linker.process(&tokens)
        }
    }

    @Test("failing backward branching declaration out of reach")
    func failingBackwardOutOfReach() {
        #expect(
            throws: AssemblerError
                .linkerError(
                    "label \"end\" declared 128 bytes away which is outside the range of a relative branching"
                )
        ) {
            var tokens: [Token] = [
                .operation(.init(code: .bvs, argument: .relative(.label("end")), address: 0)),
                .labelDeclaration(.init(name: "end", address: 130))
            ]
            try Linker.process(&tokens)
        }
    }

    @Test("tokenizer + linker test")
    func tokenizerLinker() {
        #expect(throws: Never.self, "parsed and resolved tokenks without errors") {
            var processedTokens = try Tokenizer.process(
                // code sample brought by https://skilldrick.github.io/easy6502/
                input: """
                  ldx #$08
                decrement:
                  dex
                  stx $0200
                  cpx #$03
                  bne decrement
                  stx $0201
                  brk
                """
            )
            try Linker.process(&processedTokens)
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .immediate(0x08), address: 0x0000)),
                .labelDeclaration(.init(name: "decrement", address: 0x0002)),
                .operation(.init(code: .dex, argument: .implied, address: 0x0002)),
                .operation(.init(code: .stx, argument: .absolute(.number(.word(0x0200))), address: 0x0003)),
                .operation(.init(code: .cpx, argument: .immediate(0x03), address: 0x0006)),
                .operation(.init(code: .bne, argument: .relative(.number(.byte(0xF8))), address: 0x0008)),
                .operation(.init(code: .stx, argument: .absolute(.number(.word(0x0201))), address: 0x000A)),
                .operation(.init(code: .brk, argument: .implied, address: 0x000D))
            ]
            #expect(expectedTokens == processedTokens, "parsed tokens and resolved decrement label")
        }
    }
}
