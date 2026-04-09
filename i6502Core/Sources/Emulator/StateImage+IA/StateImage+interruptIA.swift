import Foundation
import i6502Specification

extension Emulator.StateImage {
    // Executes non-maskable interruption in a "leading" cycle
    public mutating func nmiInstructionAccurate() -> Int {
        // put PC on stack
        memory[Int(registerSP) + 0x100] = UInt8((registerPC & 0xFF00) >> 8)
        registerSP &-= 1
        memory[Int(registerSP) + 0x100] = UInt8(registerPC & 0x00FF)
        registerSP &-= 1
        // pust PS (with cleared B) on stack
        memory[Int(registerSP) + 0x100] = registerPS & 0b1110_1111
        registerSP &-= 1
        // set I on actual PS
        registerPS.interrupt = true
        // jump to address in NMI_HANDLER=[FFFA..FFFB]
        registerPC = UInt16(memory[0xFFFA]) + (UInt16(memory[0xFFFB]) << 8)
        return 7
    }

    // Executes maskable interruption in a "leading" cycle
    public mutating func irqInstructionAccurate() -> Int {
        // put PC on stack
        memory[Int(registerSP) + 0x100] = UInt8((registerPC & 0xFF00) >> 8)
        registerSP &-= 1
        memory[Int(registerSP) + 0x100] = UInt8(registerPC & 0x00FF)
        registerSP &-= 1
        // pust PS (with cleared B) on stack
        memory[Int(registerSP) + 0x100] = registerPS & 0b1110_1111
        registerSP &-= 1
        // set I on actual PS
        registerPS.interrupt = true
        // jump to address in IRQ/BRK_HANDLER=[FFFE..FFFF]
        registerPC = UInt16(memory[0xFFFE]) + (UInt16(memory[0xFFFF]) << 8)
        return 7
    }

    public mutating func resetInstructionAccurate() -> Int {
        // handle three dummy stack reads
        registerSP &-= 3
        // set I (interrupts disabled)
        registerPS.interrupt = true
        // jump to address in RESET_HANDLER=[FFFC..FFFD]
        registerPC = UInt16(memory[0xFFFC]) + (UInt16(memory[0xFFFD]) << 8)
        return 7
    }
}

extension Array {
    fileprivate subscript(_ index: UInt8) -> Element {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }

    fileprivate subscript(_ index: UInt16) -> Element {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }
}
