import Testing
@testable import i6502Assembler

@Suite
struct TokenizerTests {
    // MARK: - ".define" tests

    @Test("\".define\" hex")
    func defineHex() {
        #expect(throws: Never.self, "parsed .org without errors") {
            let tokens = try Tokenizer.process(input: ".define name $50")
            #expect(tokens == [], "tokens are empty")
        }
    }

    @Test("\".define\" decimal")
    func defineDecimal() {
        #expect(throws: Never.self, "parsed .org without errors") {
            let tokens = try Tokenizer.process(input: ".define name 98")
            #expect(tokens == [], "tokens are empty")
        }
    }

    @Test("\".define\" failing decimal")
    func defineFailingDecimal() {
        #expect(throws: AssemblerError.tokenizerError("number is outside allowed range")) {
            try Tokenizer.process(input: ".define name 65536")
        }
    }

    @Test("\".define\" failing label")
    func defineFailingLabel() {
        #expect(throws: AssemblerError.tokenizerError("(0:14): expected a decimal digits or '$'")) {
            try Tokenizer.process(input: ".define name1 name2")
        }
    }

    @Test("\".define\" failing reserved name")
    func defineFailingReservedName() {
        #expect(throws: AssemblerError.tokenizerError("(0:9): \"a\" is reserved from definition")) {
            try Tokenizer.process(input: ".define a $A")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:9): \"x\" is reserved from definition")) {
            try Tokenizer.process(input: ".define x 1")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:9): \"y\" is reserved from definition")) {
            try Tokenizer.process(input: ".define y")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"nop\" is reserved from definition")) {
            try Tokenizer.process(input: ".define nop $EA")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:14): \"define\" is reserved from definition")) {
            try Tokenizer.process(input: ".define define 0")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"org\" is reserved from definition")) {
            try Tokenizer.process(input: ".define org 1")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:12): \"byte\" is reserved from definition")) {
            try Tokenizer.process(input: ".define byte 2")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:12): \"word\" is reserved from definition")) {
            try Tokenizer.process(input: ".define word 3")
        }
    }

    @Test("\".define\" failing redefenition")
    func defineFailingRedefenition() {
        #expect(throws: AssemblerError.tokenizerError("(1:9): invalid redefenition of \"F\"")) {
            try Tokenizer.process(
                input: """
                .define F $A
                .define F $B
                """
            )
        }
    }

    // MARK: - ".org" tests

    @Test("\".org\" basic")
    func orgBasic() {
        #expect(throws: Never.self, "parsed .org without errors") {
            let tokens = try Tokenizer.process(input: ".org $0600")
            #expect(tokens == [.org(0x0600)], "tokens represent exactly \".org $0600\"")
        }
    }

    @Test("\".org\" failing")
    func orgFailing() {
        #expect(throws: AssemblerError.tokenizerError("(0:4): expected a word literal after \".org\"")) {
            try Tokenizer.process(input: ".org")
        }
    }

    @Test("\".org\" failing defined byte")
    func orgFailingByteDefine() {
        #expect(throws: AssemblerError.tokenizerError("(1:8): expected a word literal after \".org\"")) {
            try Tokenizer.process(
                input: """
                .define _f0 $F0
                .org _f0
                """
            )
        }
    }

    @Test("\".org\" failing with unknown define")
    func orgFailingDefine() {
        #expect(throws: AssemblerError.tokenizerError("(0:16): expected a word literal after \".org\"")) {
            try Tokenizer.process(input: ".org NMI_HANDLER")
        }
    }

    @Test("\".org\" defined value")
    func orgDefine() {
        #expect(throws: Never.self, "parsed .org on .define without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define ISR_HANDLER $FFFE
                .org ISR_HANDLER
                """
            )
            #expect(tokens == [.org(0xFFFE)], "tokens represent exactly \".org address\"")
        }
    }

    // MARK: - ".byte" tests

    @Test("\".byte\" hex")
    func byteHex() {
        #expect(throws: Never.self, "parsed .byte without errors") {
            let tokens = try Tokenizer.process(input: ".byte $30")
            #expect(tokens == [.byte(0x30)], "tokens represent exactly \".byte $30\"")
        }
    }

    @Test("\".byte\" decimal")
    func byteDecimal() {
        #expect(throws: Never.self, "parsed .byte without errors") {
            let tokens = try Tokenizer.process(input: ".byte 255")
            #expect(tokens == [.byte(255)], "tokens represent exactly \".byte 255\"")
        }
    }

    @Test("\".byte\" negative decimal")
    func byteNegativeDecimal() {
        #expect(throws: Never.self, "parsed .byte without errors") {
            let tokens = try Tokenizer.process(input: ".byte -1")
            #expect(tokens == [.byte(255)], "tokens represent exactly \".byte 255\"")
        }
    }

    @Test("\".byte\" define")
    func byteDefine() {
        #expect(throws: Never.self, "parsed .byte without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define BLACK $00
                .byte BLACK
                """
            )
            #expect(tokens == [.byte(0)], "tokens represent exactly \".byte $00\"")
        }
    }

    @Test("\".byte\" failing hex")
    func byteFailingHex() {
        #expect(throws: AssemblerError.tokenizerError("(0:10): expected a byte literal after \".byte\"")) {
            try Tokenizer.process(input: ".byte $234")
        }
    }

    @Test("\".byte\" failing decimal")
    func byteFailingDecimal() {
        #expect(throws: AssemblerError.tokenizerError("(0:11): expected a byte literal after \".byte\"")) {
            try Tokenizer.process(input: ".byte 30000")
        }
    }

    @Test("\".byte\" failing defined word")
    func byteFailingWordDefine() {
        #expect(throws: AssemblerError.tokenizerError("(1:10): expected a byte literal after \".byte\"")) {
            try Tokenizer.process(
                input: """
                .define f0f0 $F0F0
                .byte f0f0
                """
            )
        }
    }

    @Test("\".byte\" failing unknown define")
    func byteFailingUnknownDefine() {
        #expect(throws: AssemblerError.tokenizerError("(0:9): expected a byte literal after \".byte\"")) {
            try Tokenizer.process(input: ".byte RED")
        }
    }

    // MARK: - label tests

    @Test("\"label\" basic")
    func labelBasic() {
        #expect(throws: Never.self, "parsed label without errors") {
            let tokens = try Tokenizer.process(input: "label:")
            let expectedToken = Token.labelDeclaration(
                .init(name: "label", address: 0x0000)
            )
            #expect(tokens == [expectedToken], "tokens represent exactly \"label:\"")
        }
    }

    @Test("\"label\" basic multiple")
    func labelBasicMultiple() {
        #expect(throws: Never.self, "parsed label without errors") {
            let tokens = try Tokenizer.process(input: "labelone: labeltwo: labelthree:")
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "labelone", address: 0x0000)),
                .labelDeclaration(.init(name: "labeltwo", address: 0x0000)),
                .labelDeclaration(.init(name: "labelthree", address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent three label declarations")
        }
    }

    @Test("\"label\" underscore")
    func labelBasicUnderscore() {
        #expect(throws: Never.self, "parsed label without errors") {
            let tokens = try Tokenizer.process(input: "_:")
            let expectedToken = Token.labelDeclaration(
                .init(name: "_", address: 0x0000)
            )
            #expect(tokens == [expectedToken], "tokens represent label with proper name")
        }
    }

    @Test("\"label\" failing digit")
    func labelFailingDigit() {
        #expect(throws: AssemblerError.tokenizerError("(0:0): expected letter or underscore, found \"8\"")) {
            try Tokenizer.process(input: "8:")
        }
    }

    @Test("\"label\" underscore + digit")
    func labelBasicUnderscoreDigit() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "_100:")
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "_100", address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent label with proper name")
        }
    }

    @Test("\"label\" after .org")
    func labelOrg() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .org $1234
                label:
                """
            )
            let expectedTokens: [Token] = [
                .org(0x1234),
                .labelDeclaration(.init(name: "label", address: 0x1234))
            ]
            #expect(tokens == expectedTokens, "tokens represent exactly label on $1234")
        }
    }

    @Test("\"label\" after .org with operations")
    func labelOrgOperations() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .org $1234
                nop
                nop
                label:
                """
            )
            let expectedTokens: [Token] = [
                .org(0x1234),
                .operation(.init(code: .nop, argument: .implied, address: 0x1234)),
                .operation(.init(code: .nop, argument: .implied, address: 0x1235)),
                .labelDeclaration(.init(name: "label", address: 0x1236))
            ]
            #expect(tokens == expectedTokens, "tokens represent exactly label on $1236")
        }
    }

    @Test("\"label\" after multlple .org")
    func labelOrgMultiple() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .org $0000 _0000:
                .org $0010 _0010:
                .org $0020 _0020:
                """
            )
            let expectedTokens: [Token] = [
                .org(0),
                .labelDeclaration(.init(name: "_0000", address: 0)),
                .org(0x10),
                .labelDeclaration(.init(name: "_0010", address: 0x10)),
                .org(0x20),
                .labelDeclaration(.init(name: "_0020", address: 0x20))
            ]
            #expect(tokens == expectedTokens, "tokens represent exactly label on $1234")
        }
    }

    @Test("\"label\" serial")
    func labelSerial() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "_0: _1: _2:")
            let expectedTokens: [Token] = [
                .labelDeclaration(.init(name: "_0", address: 0x0000)),
                .labelDeclaration(.init(name: "_1", address: 0x0000)),
                .labelDeclaration(.init(name: "_2", address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent labels with proper addresses")
        }
    }

    @Test("\"label\" .org label .byte combo")
    func labelOrgByte() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .org $0100
                storage: .byte $FF
                """
            )
            let expectedTokens: [Token] = [
                .org(0x0100),
                .labelDeclaration(.init(name: "storage", address: 0x0100)),
                .byte(0xFF)
            ]
            #expect(tokens == expectedTokens, "tokens represent org label byte combo")
        }
    }

    // MARK: - implied operations tests

    @Test("\"implied\" all")
    func impliedAll() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                clc sec cli sei clv cld sed nop
                tax txa dex inx tay tya dey iny
                rti rts
                txs tsx pha pla php plp brk
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .clc, argument: .implied, address: 0x0000)),
                .operation(.init(code: .sec, argument: .implied, address: 0x0001)),
                .operation(.init(code: .cli, argument: .implied, address: 0x0002)),
                .operation(.init(code: .sei, argument: .implied, address: 0x0003)),
                .operation(.init(code: .clv, argument: .implied, address: 0x0004)),
                .operation(.init(code: .cld, argument: .implied, address: 0x0005)),
                .operation(.init(code: .sed, argument: .implied, address: 0x0006)),
                .operation(.init(code: .nop, argument: .implied, address: 0x0007)),
                .operation(.init(code: .tax, argument: .implied, address: 0x0008)),
                .operation(.init(code: .txa, argument: .implied, address: 0x0009)),
                .operation(.init(code: .dex, argument: .implied, address: 0x000A)),
                .operation(.init(code: .inx, argument: .implied, address: 0x000B)),
                .operation(.init(code: .tay, argument: .implied, address: 0x000C)),
                .operation(.init(code: .tya, argument: .implied, address: 0x000D)),
                .operation(.init(code: .dey, argument: .implied, address: 0x000E)),
                .operation(.init(code: .iny, argument: .implied, address: 0x000F)),
                .operation(.init(code: .rti, argument: .implied, address: 0x0010)),
                .operation(.init(code: .rts, argument: .implied, address: 0x0011)),
                .operation(.init(code: .txs, argument: .implied, address: 0x0012)),
                .operation(.init(code: .tsx, argument: .implied, address: 0x0013)),
                .operation(.init(code: .pha, argument: .implied, address: 0x0014)),
                .operation(.init(code: .pla, argument: .implied, address: 0x0015)),
                .operation(.init(code: .php, argument: .implied, address: 0x0016)),
                .operation(.init(code: .plp, argument: .implied, address: 0x0017)),
                .operation(.init(code: .brk, argument: .implied, address: 0x0018))
            ]
            #expect(tokens == expectedTokens, "tokens represent all implied operations")
        }
    }

    @Test("\"implied\" label")
    func impliedLabel() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "nop _10:")
            let expectedTokens: [Token] = [
                .operation(.init(code: .nop, argument: .implied, address: 0x0000)),
                .labelDeclaration(.init(name: "_10", address: 0x0001))
            ]
            #expect(tokens == expectedTokens, "tokens represent implied op then label combo")
        }
    }

    @Test("\"implied\" failing immediate")
    func impliedFailingImmediate() {
        #expect(throws: AssemblerError.tokenizerError("(0:8): \"inc\" with immediate mode is illegal")) {
            try Tokenizer.process(input: "inc #$FF")
        }
    }

    @Test("\"implied\" failing absolute")
    func impliedFailingAbsolute() {
        #expect(throws: AssemblerError.tokenizerError("(0:9): \"sed\" with absolute mode is illegal")) {
            try Tokenizer.process(input: "sed $12FF")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:9): \"brk\" with absolute mode is illegal")) {
            try Tokenizer.process(input: "brk _1337")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"clc\" with absoluteX mode is illegal")) {
            try Tokenizer.process(input: "clc clear,x")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:12): \"rts\" with absoluteY mode is illegal")) {
            try Tokenizer.process(input: "rts return,y")
        }
    }

    @Test("\"implied\" failing indirect")
    func impliedFailingIndirect() {
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"cld\" with indirect mode is illegal")) {
            try Tokenizer.process(input: "cld ($FFFE)")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:16): \"nop\" with indirect mode is illegal")) {
            try Tokenizer.process(input: "nop (some_label)")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"tsx\" with indirectX mode is illegal")) {
            try Tokenizer.process(input: "tsx ($ab,x)")
        }
        #expect(throws: AssemblerError.tokenizerError("(0:11): \"tay\" with indirectY mode is illegal")) {
            try Tokenizer.process(input: "tay ($30),y")
        }
    }

    // MARK: - accumulator operations tests

    @Test("\"accumulator\" w/o argument")
    func accumulatorWithoutArgument() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "asl lsr rol ror")
            let expectedTokens: [Token] = [
                .operation(.init(code: .asl, argument: .accumulator, address: 0x0000)),
                .operation(.init(code: .lsr, argument: .accumulator, address: 0x0001)),
                .operation(.init(code: .rol, argument: .accumulator, address: 0x0002)),
                .operation(.init(code: .ror, argument: .accumulator, address: 0x0003))
            ]
            #expect(tokens == expectedTokens, "tokens represent all accumulator operations")
        }
    }

    @Test("\"accumulator\" with argument")
    func accumulatorWithArgument() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "asl a lsr a rol a ror a")
            let expectedTokens: [Token] = [
                .operation(.init(code: .asl, argument: .accumulator, address: 0x0000)),
                .operation(.init(code: .lsr, argument: .accumulator, address: 0x0001)),
                .operation(.init(code: .rol, argument: .accumulator, address: 0x0002)),
                .operation(.init(code: .ror, argument: .accumulator, address: 0x0003))
            ]
            #expect(tokens == expectedTokens, "tokens represent all accumulator operations")
        }
    }

    // MARK: - immediate operarions tests

    @Test("\"immediate\" hex")
    func immediateHex() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "adc #$10")
            let expectedTokens: [Token] = [
                .operation(.init(code: .adc, argument: .immediate(0x10), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent immediate operation")
        }
    }

    @Test("\"immediate\" decimal")
    func immediateDecimal() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "cmp #5")
            let expectedTokens: [Token] = [
                .operation(.init(code: .cmp, argument: .immediate(5), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent immediate operation")
        }
    }

    @Test("\"immediate\" negative decimal")
    func immediateNegativeDecimal() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "and #-3")
            let expectedTokens: [Token] = [
                .operation(.init(code: .and, argument: .immediate(0xFD), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent immediate operation")
        }
    }

    @Test("\"immediate\" define")
    func immediateDefine() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define b $B
                sbc #b
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .sbc, argument: .immediate(0xB), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent immediate operation")
        }
    }

    @Test("\"immediate\" failing word")
    func immediateFailingWord() {
        #expect(throws: AssemblerError.tokenizerError("(0:10): only byte values allowed in immediate mode")) {
            try Tokenizer.process(input: "eor #61234")
        }
    }

    @Test("\"immediate\" failing defined word")
    func immediateFailingWordDefine() {
        #expect(throws: AssemblerError.tokenizerError("(1:12): only byte values allowed in immediate mode")) {
            try Tokenizer.process(
                input: """
                .define address $0100
                eor #address
                """
            )
        }
    }

    @Test("\"immediate\" failing unknown define")
    func immediateFailingUnknownDefine() {
        #expect(throws: AssemblerError.tokenizerError("(0:14): unrecognized constant \"something\"")) {
            try Tokenizer.process(input: "cpy #something")
        }
    }

    @Test("\"immediate\" failing illegal")
    func immediateFailingIllegal() {
        #expect(throws: AssemblerError.tokenizerError("(0:8): \"stx\" with immediate mode is illegal")) {
            try Tokenizer.process(input: "stx #$13")
        }
    }

    // MARK: - zero page operations tests

    @Test("\"zero page\" hex")
    func zeroPageHex() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "adc $FE")
            let expectedTokens: [Token] = [
                .operation(.init(code: .adc, argument: .zeroPage(0xFE), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "sbc $00,x")
            let expectedTokens: [Token] = [
                .operation(.init(code: .sbc, argument: .zeroPageX(0x00), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "ldx $dd,y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .zeroPageY(0xDD), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page Y operation")
        }
    }

    @Test("\"zero page\" decimal")
    func zeroPageDecimal() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "sta 5")
            let expectedTokens: [Token] = [
                .operation(.init(code: .sta, argument: .zeroPage(5), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "and 55,x")
            let expectedTokens: [Token] = [
                .operation(.init(code: .and, argument: .zeroPageX(55), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "stx 255,y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .stx, argument: .zeroPageY(255), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page Y operation")
        }
    }

    @Test("\"zero page\" define")
    func zeroPageDefine() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define MASK_REF 255
                bit MASK_REF
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .bit, argument: .zeroPage(255), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define WHITE 255
                cmp WHITE,x
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .cmp, argument: .zeroPageX(255), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define offset $8 
                ldx offset,y
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .zeroPageY(8), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent zero page Y operation")
        }
    }

    // MARK: - absolute operations tests

    @Test("\"absolute\" hex")
    func absoluteHex() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "adc $0100")
            let expectedTokens: [Token] = [
                .operation(.init(code: .adc, argument: .absolute(.number(.word(0x0100))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "sbc $0200,x")
            let expectedTokens: [Token] = [
                .operation(.init(code: .sbc, argument: .absoluteX(.number(.word(0x0200))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "ldx $0300,y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .absoluteY(.number(.word(0x0300))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    @Test("\"absolute\" decimal")
    func absoluteDecimal() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "adc 256")
            let expectedTokens: [Token] = [
                .operation(.init(code: .adc, argument: .absolute(.number(.word(256))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "sbc 257,x")
            let expectedTokens: [Token] = [
                .operation(.init(code: .sbc, argument: .absoluteX(.number(.word(257))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "ldx 258,y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .absoluteY(.number(.word(258))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    @Test("\"absolute\" define")
    func absoluteDefine() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define MASK_REF 65535
                bit MASK_REF
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .bit, argument: .absolute(.number(.word(65_535))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define EOF 65535
                cmp EOF,x
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .cmp, argument: .absoluteX(.number(.word(65_535))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define offset_ref $0100
                ldx offset_ref,y
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .absoluteY(.number(.word(0x0100))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    @Test("\"absolute\" label")
    func absoluteLabel() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "adc constant")
            let expectedTokens: [Token] = [
                .operation(.init(code: .adc, argument: .absolute(.label("constant")), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "sbc label,x")
            let expectedTokens: [Token] = [
                .operation(.init(code: .sbc, argument: .absoluteX(.label("label")), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "ldx asd,y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .ldx, argument: .absoluteY(.label("asd")), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    // MARK: - indirect operations tests

    @Test("\"indirect\" hex")
    func indirectHex() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "jmp ($FFFE)")
            let expectedTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .indirect(.number(.word(0xFFFE))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "eor ($44,x)")
            let expectedTokens: [Token] = [
                .operation(.init(code: .eor, argument: .indirectX(0x44), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "lda ($77),y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .lda, argument: .indirectY(0x77), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
    }

    @Test("\"indirect\" decimal")
    func indirectDecimal() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "jmp (500)")
            let expectedTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .indirect(.number(.word(500))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "lda (50,x)")
            let expectedTokens: [Token] = [
                .operation(.init(code: .lda, argument: .indirectX(50), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "ora (77),y")
            let expectedTokens: [Token] = [
                .operation(.init(code: .ora, argument: .indirectY(77), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    @Test("\"indirect\" define")
    func indirectDefine() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define SECTION_A_REF $0A00
                jmp (SECTION_A_REF)
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .indirect(.number(.word(0x0A00))), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define ST $DD
                lda (ST,x)
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .lda, argument: .indirectX(0xDD), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute X operation")
        }
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define def 77
                ora (def),y
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .ora, argument: .indirectY(77), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute Y operation")
        }
    }

    @Test("\"indirect\" label")
    func indirectLabel() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "jmp (label_name)")
            let expectedTokens: [Token] = [
                .operation(.init(code: .jmp, argument: .indirect(.label("label_name")), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent absolute operation")
        }
    }

    // MARK: - relative operations tests

    @Test("\"relative\" label")
    func relativeLabel() {
        #expect(throws: Never.self, "parsed without errors") {
            let tokens = try Tokenizer.process(input: "bpl qqq")
            let expectedTokens: [Token] = [
                .operation(.init(code: .bpl, argument: .relative(.label("qqq")), address: 0x0000))
            ]
            #expect(tokens == expectedTokens, "tokens represent relative operation")
        }
    }

    @Test("\"relative\" failing number")
    func relativeFailingNumber() {
        #expect(throws: AssemblerError.tokenizerError("(0:7): \"bmi\" with zeroPage mode is illegal")) {
            try Tokenizer.process(input: "bmi $01")
        }
    }

    // MARK: - misc tests

    @Test("\"misc\" empty input")
    func miscEmpty() {
        #expect(throws: Never.self, "parsed empty input without errors") {
            let tokens = try Tokenizer.process(input: "")
            #expect(tokens == [], "tokens are empty")
        }
    }

    @Test("\"misc\" whitespaces input")
    func miscWhitespaces() {
        #expect(throws: Never.self, "parsed empty input without errors") {
            let tokens = try Tokenizer.process(input: "  \t \t \n    \t")
            #expect(tokens == [], "tokens are empty")
        }
    }

    @Test("\"misc\" comments")
    func miscComments() {
        #expect(throws: Never.self, "parsed input without errors") {
            let tokens = try Tokenizer.process(
                input: """
                ; full line of comment
                .define white_color $FF   ; define byte with comment
                .define monitor     $0600 ; define word with comment

                .org monitor              ; org with comment 
                .byte white_color         ; byte with comment

                .org $0000                ; org with comment
                lda #white_color          ; op with comment

                ; commented op
                ; ldx #white_color
                """
            )
            let expectedTokens: [Token] = [
                .org(0x600),
                .byte(0xFF),
                .org(0),
                .operation(.init(code: .lda, argument: .immediate(0xFF), address: 0))
            ]
            #expect(tokens == expectedTokens, "tokens are not corrupted by comments")
        }
    }

    @Test("\"misc\" address progression")
    func miscAddressProgress() {
        #expect(throws: Never.self, "parsed empty input without errors") {
            let tokens = try Tokenizer.process(
                input: """
                lda #$01  ; 2 bytes
                sta $0200 ; 3 bytes
                nop       ; 1 byte
                .byte $f0 ; 1 byte
                end:
                """
            )
            let expectedTokens: [Token] = [
                .operation(.init(code: .lda, argument: .immediate(0x01), address: 0)),
                .operation(.init(code: .sta, argument: .absolute(.number(.word(0x0200))), address: 2)),
                .operation(.init(code: .nop, argument: .implied, address: 5)),
                .byte(0xF0),
                .labelDeclaration(.init(name: "end", address: 7))
            ]
            #expect(tokens == expectedTokens, "tokens are not corrupted by comments")
        }
    }

    @Test("\"misc\" sample code")
    func miscSampleCode() {
        #expect(throws: Never.self, "parsed input without errors") {
            let tokens = try Tokenizer.process(
                input: """
                .define SCREEN $0200
                .define BLACK  $00

                .org $0600
                start:
                    lda #BLACK       ; load color
                    sta SCREEN       ; store to screen
                    inx
                    bne start        ; loop
                    brk
                """
            )
            let expectedTokens: [Token] = [
                .org(0x0600),
                .labelDeclaration(.init(name: "start", address: 0x0600)),
                .operation(.init(code: .lda, argument: .immediate(0x00), address: 0x0600)),
                .operation(.init(code: .sta, argument: .absolute(.number(.word(0x0200))), address: 0x0602)),
                .operation(.init(code: .inx, argument: .implied, address: 0x0605)),
                .operation(.init(code: .bne, argument: .relative(.label("start")), address: 0x0606)),
                .operation(.init(code: .brk, argument: .implied, address: 0x0608))
            ]
            #expect(tokens == expectedTokens, "tokens represent actual program instructions")
        }
    }
}
