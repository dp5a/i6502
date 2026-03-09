
public enum OperationCode: String, Codable, Hashable, Sendable {
    case adc // ADd with Carry
    case and // bitwise AND with accumulator
    case asl // Arithmetic Shift Left
    case bit // test BITs

    case bpl // Branch on PLus
    case bmi // Branch on MInus
    case bvc // Branch on oVerflow Clear
    case bvs // Branch on oVerflow Set
    case bcc // Branch on Carry Clear
    case bcs // Branch on Carry Set
    case bne // Branch on Not Equal
    case beq // Branch on EQual

    case brk // BReaK
    case cmp // CoMPare accumulator
    case cpx // ComPare X register
    case cpy // ComPare Y register
    case dec // DECrement memory
    case eor // bitwise Exclusive OR

    case clc // CLear Carry
    case sec // SEt Carry
    case cli // CLear Interrupt
    case sei // SEt Interrupt
    case clv // CLear oVerflow
    case cld // CLear Decimal
    case sed // SEt Decimal

    case inc // INCrement memory
    case jmp // JuMP
    case jsr // Jump to SubRoutine
    case lda // LoaD Accumulator
    case ldx // LoaD X register
    case ldy // LoaD Y register
    case lsr // Logical Shift Right
    case nop // No OPeration
    case ora // bitwise OR with Accumulator

    case tax // Transfer A to X
    case txa // Transfer X to A
    case dex // DEcrement X
    case inx // INcrement X
    case tay // Transfer A to Y
    case tya // Transfer Y to A
    case dey // DEcrement Y
    case iny // INcrement Y

    case rol // ROtate Left
    case ror // ROtate Right
    case rti // ReTurn from Interrupt
    case rts // ReTurn from Subroutine
    case sbc // SuBtract with Carry
    case sta // STore Accumulator

    case txs // Transfer X to Stack ptr
    case tsx // Transfer Stack ptr to X
    case pha // PusH Accumulator
    case pla // PuLl Accumulator
    case php // PusH Processor status
    case plp // PuLl Processor status

    case stx // STore X register
    case sty // STore Y register
}

public enum AddressingMode: Hashable, Sendable {
    // #$value
    case immediate

    // $value (where value $00..$ff)
    case zeroPage

    // $value,X (where value $00..$ff)
    case zeroPageX

    // $value,Y (where value $00..$ff)
    case zeroPageY

    // $value (where value $0000..$ffff)
    case absolute

    // $value,X (where value $0000..$ffff)
    case absoluteX

    // $value,Y (where value $0000..$ffff)
    case absoluteY

    // Indexed indirect: ($value,X)
    case indirectX

    // Indirect indexed: ($value),Y
    case indirectY

    // ($value)
    case indirect

    // Represented as label in assembly and signed byte offset in bytecode
    case relative

    // Operation without argument
    case implied

    // Operation on register A
    case accumulator
}

public struct Operation: Hashable, Sendable {
    public let symbol: OperationCode
    public let mode: AddressingMode

    public init(_ symbol: OperationCode, _ mode: AddressingMode) {
        self.symbol = symbol
        self.mode = mode
    }

    public var length: UInt16 {
        // all op codes take exactly one byte
        // lenght depends only on addressing mode
        switch mode {
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

extension Operation {
    public var baseTiming: Int? {
        switch (symbol, mode) {
        case (.adc, .immediate): 2
        case (.adc, .zeroPage): 3
        case (.adc, .zeroPageX): 4
        case (.adc, .absolute): 4
        case (.adc, .absoluteX): 4
        case (.adc, .absoluteY): 4
        case (.adc, .indirectX): 6
        case (.adc, .indirectY): 5

        case (.and, .immediate): 2
        case (.and, .zeroPage): 3
        case (.and, .zeroPageX): 4
        case (.and, .absolute): 4
        case (.and, .absoluteX): 4
        case (.and, .absoluteY): 4
        case (.and, .indirectX): 6
        case (.and, .indirectY): 5

        case (.asl, .accumulator): 2
        case (.asl, .zeroPage): 5
        case (.asl, .zeroPageX): 6
        case (.asl, .absolute): 6
        case (.asl, .absoluteX): 7

        case (.bit, .zeroPage): 3
        case (.bit, .absolute): 4

        case (.bpl, .relative): 2
        case (.bmi, .relative): 2
        case (.bvc, .relative): 2
        case (.bvs, .relative): 2
        case (.bcc, .relative): 2
        case (.bcs, .relative): 2
        case (.bne, .relative): 2
        case (.beq, .relative): 2

        case (.brk, .implied): 7

        case (.cmp, .immediate): 2
        case (.cmp, .zeroPage): 3
        case (.cmp, .zeroPageX): 4
        case (.cmp, .absolute): 4
        case (.cmp, .absoluteX): 4
        case (.cmp, .absoluteY): 4
        case (.cmp, .indirectX): 6
        case (.cmp, .indirectY): 5

        case (.cpx, .immediate): 2
        case (.cpx, .zeroPage): 3
        case (.cpx, .absolute): 4

        case (.cpy, .immediate): 2
        case (.cpy, .zeroPage): 3
        case (.cpy, .absolute): 4

        case (.dec, .zeroPage): 5
        case (.dec, .zeroPageX): 6
        case (.dec, .absolute): 6
        case (.dec, .absoluteX): 7

        case (.eor, .immediate): 2
        case (.eor, .zeroPage): 3
        case (.eor, .zeroPageX): 4
        case (.eor, .absolute): 4
        case (.eor, .absoluteX): 4
        case (.eor, .absoluteY): 4
        case (.eor, .indirectX): 6
        case (.eor, .indirectY): 5

        case (.clc, .implied): 2
        case (.sec, .implied): 2
        case (.cli, .implied): 2
        case (.sei, .implied): 2
        case (.clv, .implied): 2
        case (.cld, .implied): 2
        case (.sed, .implied): 2

        case (.inc, .zeroPage): 5
        case (.inc, .zeroPageX): 6
        case (.inc, .absolute): 6
        case (.inc, .absoluteX): 7

        case (.jmp, .absolute): 3
        case (.jmp, .indirect): 5

        case (.jsr, .absolute): 6

        case (.lda, .immediate): 2
        case (.lda, .zeroPage): 3
        case (.lda, .zeroPageX): 4
        case (.lda, .absolute): 4
        case (.lda, .absoluteX): 4
        case (.lda, .absoluteY): 4
        case (.lda, .indirectX): 6
        case (.lda, .indirectY): 5

        case (.ldx, .immediate): 2
        case (.ldx, .zeroPage): 3
        case (.ldx, .zeroPageY): 4
        case (.ldx, .absolute): 4
        case (.ldx, .absoluteY): 4

        case (.ldy, .immediate): 2
        case (.ldy, .zeroPage): 3
        case (.ldy, .zeroPageX): 4
        case (.ldy, .absolute): 4
        case (.ldy, .absoluteX): 4

        case (.lsr, .accumulator): 2
        case (.lsr, .zeroPage): 5
        case (.lsr, .zeroPageX): 6
        case (.lsr, .absolute): 6
        case (.lsr, .absoluteX): 7

        case (.nop, .implied): 2

        case (.ora, .immediate): 2
        case (.ora, .zeroPage): 3
        case (.ora, .zeroPageX): 4
        case (.ora, .absolute): 4
        case (.ora, .absoluteX): 4
        case (.ora, .absoluteY): 4
        case (.ora, .indirectX): 6
        case (.ora, .indirectY): 5

        case (.tax, .implied): 2
        case (.txa, .implied): 2
        case (.dex, .implied): 2
        case (.inx, .implied): 2
        case (.tay, .implied): 2
        case (.tya, .implied): 2
        case (.dey, .implied): 2
        case (.iny, .implied): 2

        case (.rol, .accumulator): 2
        case (.rol, .zeroPage): 5
        case (.rol, .zeroPageX): 6
        case (.rol, .absolute): 6
        case (.rol, .absoluteX): 7

        case (.ror, .accumulator): 2
        case (.ror, .zeroPage): 5
        case (.ror, .zeroPageX): 6
        case (.ror, .absolute): 6
        case (.ror, .absoluteX): 7

        case (.rti, .implied): 6
        case (.rts, .implied): 6

        case (.sbc, .immediate): 2
        case (.sbc, .zeroPage): 3
        case (.sbc, .zeroPageX): 4
        case (.sbc, .absolute): 4
        case (.sbc, .absoluteX): 4
        case (.sbc, .absoluteY): 4
        case (.sbc, .indirectX): 6
        case (.sbc, .indirectY): 5

        case (.sta, .zeroPage): 3
        case (.sta, .zeroPageX): 4
        case (.sta, .absolute): 4
        case (.sta, .absoluteX): 5
        case (.sta, .absoluteY): 5
        case (.sta, .indirectX): 6
        case (.sta, .indirectY): 6

        case (.txs, .implied): 2
        case (.tsx, .implied): 2
        case (.pha, .implied): 3
        case (.pla, .implied): 4
        case (.php, .implied): 3
        case (.plp, .implied): 4

        case (.stx, .zeroPage): 3
        case (.stx, .zeroPageY): 4
        case (.stx, .absolute): 4

        case (.sty, .zeroPage): 3
        case (.sty, .zeroPageX): 4
        case (.sty, .absolute): 4
        default: nil
        }
    }
}

public enum Specification {
    public static let branchingOperations: Set<OperationCode> = [.bpl, .bmi, .bvc, .bvs, .bcc, .bcs, .bne, .beq]

    public static let allowedModes: [OperationCode: Set<AddressingMode>] = [
        .adc: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .and: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .asl: [.accumulator, .zeroPage, .zeroPageX, .absolute, .absoluteX],
        .bit: [.zeroPage, .absolute],
        .bpl: [.relative],
        .bmi: [.relative],
        .bvc: [.relative],
        .bvs: [.relative],
        .bcc: [.relative],
        .bcs: [.relative],
        .bne: [.relative],
        .beq: [.relative],
        .brk: [.implied],
        .cmp: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .cpx: [.immediate, .zeroPage, .absolute],
        .cpy: [.immediate, .zeroPage, .absolute],
        .dec: [.zeroPage, .zeroPageX, .absolute, .absoluteX],
        .eor: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .clc: [.implied],
        .sec: [.implied],
        .cli: [.implied],
        .sei: [.implied],
        .clv: [.implied],
        .cld: [.implied],
        .sed: [.implied],
        .inc: [.zeroPage, .zeroPageX, .absolute, .absoluteX],
        .jmp: [.absolute, .absolute, .absoluteX, .indirect],
        .jsr: [.absolute],
        .lda: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .ldx: [.immediate, .zeroPage, .zeroPageY, .absolute, .absoluteY],
        .ldy: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX],
        .lsr: [.accumulator, .zeroPage, .zeroPageX, .absolute, .absoluteX],
        .nop: [.implied],
        .ora: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .tax: [.implied],
        .txa: [.implied],
        .dex: [.implied],
        .inx: [.implied],
        .tay: [.implied],
        .tya: [.implied],
        .dey: [.implied],
        .iny: [.implied],
        .rol: [.accumulator, .zeroPage, .zeroPageX, .absolute, .absoluteX],
        .rti: [.implied],
        .rts: [.implied],
        .sbc: [.immediate, .zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .sta: [.zeroPage, .zeroPageX, .absolute, .absoluteX, .absoluteY, .indirectX, .indirectY],
        .txs: [.implied],
        .tsx: [.implied],
        .pha: [.implied],
        .pla: [.implied],
        .php: [.implied],
        .plp: [.implied],
        .stx: [.zeroPage, .zeroPageY, .absolute],
        .sty: [.zeroPage, .zeroPageX, .absolute]
    ]

    fileprivate static let bytecodes: [Operation: UInt8] = [
        .init(.adc, .immediate): 0x69,
        .init(.adc, .zeroPage): 0x65,
        .init(.adc, .zeroPageX): 0x75,
        .init(.adc, .absolute): 0x6D,
        .init(.adc, .absoluteX): 0x7D,
        .init(.adc, .absoluteY): 0x79,
        .init(.adc, .indirectX): 0x61,
        .init(.adc, .indirectY): 0x71,

        .init(.and, .immediate): 0x29,
        .init(.and, .zeroPage): 0x25,
        .init(.and, .zeroPageX): 0x35,
        .init(.and, .absolute): 0x2D,
        .init(.and, .absoluteX): 0x3D,
        .init(.and, .absoluteY): 0x39,
        .init(.and, .indirectX): 0x21,
        .init(.and, .indirectY): 0x31,

        .init(.asl, .accumulator): 0x0A,
        .init(.asl, .zeroPage): 0x06,
        .init(.asl, .zeroPageX): 0x15,
        .init(.asl, .absolute): 0x0E,
        .init(.asl, .absoluteX): 0x1E,

        .init(.bit, .zeroPage): 0x24,
        .init(.bit, .absolute): 0x2C,

        .init(.bpl, .relative): 0x10,
        .init(.bmi, .relative): 0x30,
        .init(.bvc, .relative): 0x50,
        .init(.bvs, .relative): 0x70,
        .init(.bcc, .relative): 0x90,
        .init(.bcs, .relative): 0xB0,
        .init(.bne, .relative): 0xD0,
        .init(.beq, .relative): 0xF0,
        .init(.brk, .implied): 0x00,

        .init(.cmp, .immediate): 0xC9,
        .init(.cmp, .zeroPage): 0xC5,
        .init(.cmp, .zeroPageX): 0xD5,
        .init(.cmp, .absolute): 0xCD,
        .init(.cmp, .absoluteX): 0xDD,
        .init(.cmp, .absoluteY): 0xD9,
        .init(.cmp, .indirectX): 0xC1,
        .init(.cmp, .indirectY): 0xD1,

        .init(.cpx, .immediate): 0xE0,
        .init(.cpx, .zeroPage): 0xE4,
        .init(.cpx, .absolute): 0xEC,

        .init(.cpy, .immediate): 0xC0,
        .init(.cpy, .zeroPage): 0xC4,
        .init(.cpy, .absolute): 0xCC,

        .init(.dec, .zeroPage): 0xC6,
        .init(.dec, .zeroPageX): 0xD6,
        .init(.dec, .absolute): 0xCE,
        .init(.dec, .absoluteX): 0xDE,

        .init(.eor, .immediate): 0x49,
        .init(.eor, .zeroPage): 0x45,
        .init(.eor, .zeroPageX): 0x55,
        .init(.eor, .absolute): 0x4D,
        .init(.eor, .absoluteX): 0x5D,
        .init(.eor, .absoluteY): 0x59,
        .init(.eor, .indirectX): 0x41,
        .init(.eor, .indirectY): 0x51,

        .init(.clc, .implied): 0x18,
        .init(.sec, .implied): 0x38,
        .init(.cli, .implied): 0x58,
        .init(.sei, .implied): 0x78,
        .init(.clv, .implied): 0xB8,
        .init(.cld, .implied): 0xD8,
        .init(.sed, .implied): 0xF8,

        .init(.inc, .zeroPage): 0xE6,
        .init(.inc, .zeroPageX): 0xF6,
        .init(.inc, .absolute): 0xEE,
        .init(.inc, .absoluteX): 0xFE,

        .init(.jmp, .absolute): 0x4C,
        .init(.jmp, .indirect): 0x6C,

        .init(.jsr, .absolute): 0x20,

        .init(.lda, .immediate): 0xA9,
        .init(.lda, .zeroPage): 0xA5,
        .init(.lda, .zeroPageX): 0xB5,
        .init(.lda, .absolute): 0xAD,
        .init(.lda, .absoluteX): 0xBD,
        .init(.lda, .absoluteY): 0xB9,
        .init(.lda, .indirectX): 0xA1,
        .init(.lda, .indirectY): 0xB1,

        .init(.ldx, .immediate): 0xA2,
        .init(.ldx, .zeroPage): 0xA6,
        .init(.ldx, .zeroPageY): 0xB6,
        .init(.ldx, .absolute): 0xAE,
        .init(.ldx, .absoluteY): 0xBE,

        .init(.ldy, .immediate): 0xA0,
        .init(.ldy, .zeroPage): 0xA4,
        .init(.ldy, .zeroPageX): 0xB4,
        .init(.ldy, .absolute): 0xAC,
        .init(.ldy, .absoluteX): 0xBC,

        .init(.lsr, .accumulator): 0x4A,
        .init(.lsr, .zeroPage): 0x46,
        .init(.lsr, .zeroPageX): 0x56,
        .init(.lsr, .absolute): 0x4E,
        .init(.lsr, .absoluteX): 0x5E,

        .init(.nop, .implied): 0xEA,

        .init(.ora, .immediate): 0x09,
        .init(.ora, .zeroPage): 0x05,
        .init(.ora, .zeroPageX): 0x15,
        .init(.ora, .absolute): 0x0D,
        .init(.ora, .absoluteX): 0x1D,
        .init(.ora, .absoluteY): 0x19,
        .init(.ora, .indirectX): 0x01,
        .init(.ora, .indirectY): 0x11,

        .init(.tax, .implied): 0xAA,
        .init(.txa, .implied): 0x8A,
        .init(.dex, .implied): 0xCA,
        .init(.inx, .implied): 0xE8,
        .init(.tay, .implied): 0xA8,
        .init(.tya, .implied): 0x98,
        .init(.dey, .implied): 0x88,
        .init(.iny, .implied): 0xC8,

        .init(.rol, .accumulator): 0x2A,
        .init(.rol, .zeroPage): 0x26,
        .init(.rol, .zeroPageX): 0x36,
        .init(.rol, .absolute): 0x2E,
        .init(.rol, .absoluteX): 0x3E,

        .init(.ror, .accumulator): 0x6A,
        .init(.ror, .zeroPage): 0x66,
        .init(.ror, .zeroPageX): 0x76,
        .init(.ror, .absolute): 0x6E,
        .init(.ror, .absoluteX): 0x7E,

        .init(.rti, .implied): 0x40,
        .init(.rts, .implied): 0x60,

        .init(.sbc, .immediate): 0xE9,
        .init(.sbc, .zeroPage): 0xE5,
        .init(.sbc, .zeroPageX): 0xF5,
        .init(.sbc, .absolute): 0xED,
        .init(.sbc, .absoluteX): 0xFD,
        .init(.sbc, .absoluteY): 0xF9,
        .init(.sbc, .indirectX): 0xE1,
        .init(.sbc, .indirectY): 0xF1,

        .init(.sta, .zeroPage): 0x85,
        .init(.sta, .zeroPageX): 0x95,
        .init(.sta, .absolute): 0x8D,
        .init(.sta, .absoluteX): 0x9D,
        .init(.sta, .absoluteY): 0x99,
        .init(.sta, .indirectX): 0x81,
        .init(.sta, .indirectY): 0x91,

        .init(.txs, .implied): 0x9A,
        .init(.tsx, .implied): 0xBA,
        .init(.pha, .implied): 0x48,
        .init(.pla, .implied): 0x68,
        .init(.php, .implied): 0x08,
        .init(.plp, .implied): 0x28,

        .init(.stx, .zeroPage): 0x86,
        .init(.stx, .zeroPageY): 0x96,
        .init(.stx, .absolute): 0x8E,

        .init(.sty, .zeroPage): 0x84,
        .init(.sty, .zeroPageX): 0x94,
        .init(.sty, .absolute): 0x8C
    ]

    fileprivate static let operations: [UInt8: Operation] =
        Dictionary(uniqueKeysWithValues: bytecodes.map { ($1, $0) })

    public static func translate(byte: UInt8) -> Operation? {
        operations[byte]
    }

    public static func translate(op: Operation) -> UInt8? {
        bytecodes[op]
    }
}
