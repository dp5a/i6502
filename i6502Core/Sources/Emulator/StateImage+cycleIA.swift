import Foundation
import i6502Specification

extension Emulator.StateImage {
    // Returns timings of processed operation
    public mutating func cycleInstructionAccurate() throws -> Int {
        guard let operation = Specification.translate(byte: memory[Int(registerPC)]) else {
            throw EmulatorError.stateCycleError(
                "Byte \(String(format: "%.2x", Int(memory[Int(registerPC)]))) is illegal opcode!"
            )
        }
        guard let baseTiming = operation.baseTiming else {
            throw EmulatorError.stateCycleError("No base timing for operation '\(operation)'")
        }

        let (operandValue, hopTiming) = fetchOperand(operation)
        let executionTiming = executeOperation(operation, operandValue)
        return baseTiming + hopTiming + executionTiming
    }

    private func executeOperation(
        _ operation: i6502Specification.Operation,
        _ operand: UInt8?
    ) -> Int {
        switch operation.symbol {
        case .adc: break
        case .and: break
        case .asl: break
        case .bit: break
        case .bpl: break
        case .bmi: break
        case .bvc: break
        case .bvs: break
        case .bcc: break
        case .bcs: break
        case .bne: break
        case .beq: break
        case .brk: break
        case .cmp: break
        case .cpx: break
        case .cpy: break
        case .dec: break
        case .eor: break
        case .clc: break
        case .sec: break
        case .cli: break
        case .sei: break
        case .clv: break
        case .cld: break
        case .sed: break
        case .inc: break
        case .jmp: break
        case .jsr: break
        case .lda: break
        case .ldx: break
        case .ldy: break
        case .lsr: break
        case .nop: break
        case .ora: break
        case .tax: break
        case .txa: break
        case .dex: break
        case .inx: break
        case .tay: break
        case .tya: break
        case .dey: break
        case .iny: break
        case .rol: break
        case .ror: break
        case .rti: break
        case .rts: break
        case .sbc: break
        case .sta: break
        case .txs: break
        case .tsx: break
        case .pha: break
        case .pla: break
        case .php: break
        case .plp: break
        case .stx: break
        case .sty: break
        }
        return 0
    }

    private func fetchOperand(
        _ op: i6502Specification.Operation
    ) -> (value: UInt8?, additionalTiming: Int) {
        let nextPC = Int(registerPC + 1)
        let nextByte: UInt8 = memory[nextPC]
        let nextWord = UInt16(nextByte) &+ UInt16(memory[nextPC + 1]) >> 8

        let value: UInt8? = switch op.mode {
        case .immediate:
            nextByte
        case .zeroPage:
            memory[nextByte]
        case .zeroPageX:
            memory[nextByte &+ registerX]
        case .zeroPageY:
            memory[nextByte &+ registerY]
        case .absolute:
            memory[nextWord]
        case .absoluteX:
            memory[nextWord &+ UInt16(registerX)]
        case .absoluteY:
            memory[nextWord &+ UInt16(registerY)]
        case .indirectX:
            memory[UInt16(memory[nextByte &+ registerX]) &+ UInt16(memory[nextByte &+ registerX &+ 1] >> 8)]
        case .indirectY:
            memory[UInt16(memory[nextWord]) &+ UInt16(memory[nextWord + 1] >> 8) &+ UInt16(registerY)]
        case .indirect:
            memory[UInt16(memory[nextWord]) &+ UInt16(memory[nextWord + 1] >> 8)]
        case .relative:
            memory[Int8(bitPattern: UInt8(registerPC & 0xFF)) &+ Int8(bitPattern: nextByte)]
        case .implied, .accumulator:
            nil
        }
        return (value, 0)
    }
}

extension Array {
    fileprivate subscript(_ index: UInt8) -> Element {
        self[Int(index)]
    }

    fileprivate subscript(_ index: Int8) -> Element {
        self[Int(UInt8(bitPattern: index))]
    }

    fileprivate subscript(_ index: UInt16) -> Element {
        self[Int(index)]
    }
}
