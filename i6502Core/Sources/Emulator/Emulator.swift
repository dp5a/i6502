import i6502CEmulator

/* Emulator facade for Swift API */
public class Emulator {
    private var state: OpaquePointer

    public init() {
        state = emu_create()
    }

    public func boot(memory: [UInt8?]) {
        write(memory: memory)
        emu_reset(state)
    }

    public func reset() {
        emu_reset(state)
    }

    public func cycle() {
        emu_cycle(state)
    }

    public func nmi(_ isOn: Bool) {
        emu_nmi_line(state, isOn)
    }

    public func irq(_ isOn: Bool) {
        emu_irq_line(state, isOn)
    }

    public func read(at address: UInt16) -> UInt8 {
        emu_read(state, address)
    }

    public func write(_ value: UInt8?, at address: UInt16) {
        if let value {
            emu_write(state, address, value)
        }
    }

    public func read(at range: Range<UInt16>) -> [UInt8] {
        range.map { self.read(at: $0) }
    }

    public func write(memory: [UInt8?]) {
        for (address, value) in memory.enumerated() {
            write(value, at: UInt16(address))
        }
    }

    deinit {
        emu_destroy(state)
    }
}
