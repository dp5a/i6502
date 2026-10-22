import Foundation
import i6502CEmulator

/* Emulator facade for Swift API */
public class Emulator {
    public struct NESButton: OptionSet, Sendable {
        public let rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }

        public static let a = NESButton(rawValue: 1 << 0)
        public static let b = NESButton(rawValue: 1 << 1)
        public static let select = NESButton(rawValue: 1 << 2)
        public static let start = NESButton(rawValue: 1 << 3)
        public static let up = NESButton(rawValue: 1 << 4)
        public static let down = NESButton(rawValue: 1 << 5)
        public static let left = NESButton(rawValue: 1 << 6)
        public static let right = NESButton(rawValue: 1 << 7)
    }

    public func setController(_ buttons: NESButton, player: UInt8 = 0) {
        emu_set_controller(state, player, buttons.rawValue)
    }

    private var state: OpaquePointer
    private let game_ptr: UnsafeMutablePointer<UInt8>

    public init(rom: Data) {
        game_ptr = UnsafeMutablePointer.allocate(capacity: rom.count)
        rom.copyBytes(to: game_ptr, count: rom.count)
        state = emu_create(game_ptr, UInt32(rom.count))
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

    public func framebuffer() -> [UInt32] {
        Array(UnsafeBufferPointer(start: emu_framebuffer(state), count: 256 * 240))
    }

    deinit {
        emu_destroy(state)
    }
}
