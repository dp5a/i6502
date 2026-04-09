
extension Emulator {
    public struct StateImage {
        public var registerPC: UInt16
        public var registerSP: UInt8
        public var registerA: UInt8
        public var registerX: UInt8
        public var registerY: UInt8
        public var registerPS: ProcessorStatus
        public var memory: [UInt8] // 64 KiB

        public init(
            registerPC: UInt16,
            registerSP: UInt8,
            registerA: UInt8,
            registerX: UInt8,
            registerY: UInt8,
            registerPS: UInt8,
            memory: [UInt8]
        ) {
            self.registerPC = registerPC
            self.registerSP = registerSP
            self.registerA = registerA
            self.registerX = registerX
            self.registerY = registerY
            self.registerPS = registerPS
            self.memory = memory
        }

        public init() {
            self.init(
                registerPC: 0x0000,
                registerSP: UInt8.random(in: 0 ... 255),
                registerA: UInt8.random(in: 0 ... 255),
                registerX: UInt8.random(in: 0 ... 255),
                registerY: UInt8.random(in: 0 ... 255),
                registerPS: UInt8.random(in: 0 ... 255) | 0b0000_0100,
                memory: (0 ..< 65_536).map { _ in UInt8.random(in: 0 ... 255) }
            )

            // TODO: remove it.
            // temp gimmick to clean monitor memory and force decimal mode off
            //   * should support ADC & SBC in BCD-mode
            //   * should flush screen in program (boring...) or pretend that monitor can write to memory
            try? memory.assign(at: 0x200 ... 0x5FF, Array(repeating: 0, count: 1_024))
            registerSP.decimal = false
        }
    }

    public typealias ProcessorStatus = UInt8
}

extension Emulator.ProcessorStatus {
    // Negative flag: result of last operation
    // is negative in 2's complement
    public var negative: Bool {
        get { (self & 0b1000_0000) >> 7 == 1 }
        set {
            if newValue {
                self |= (1 << 7)
            } else {
                self &= ~(1 << 7)
            }
        }
    }

    // oVerflow flag: result of last operation
    // overflowed in signed
    public var overflow: Bool {
        get { (self & 0b0100_0000) >> 6 == 1 }
        set {
            if newValue {
                self |= (1 << 6)
            } else {
                self &= ~(1 << 6)
            }
        }
    }

    // unused bit
    public var skip: Bool { true }

    // Break flag: not an actual flag
    // rather a value that injected in stack
    // while handling interrupts
    // to distinguish brk from nmi/irq
    public var `break`: Bool {
        get { (self & 0b0001_0000) >> 4 == 1 }
        set {
            if newValue {
                self |= (1 << 4)
            } else {
                self &= ~(1 << 4)
            }
        }
    }

    // Decimal flag: computation for adc/sbc
    // is done in 10-notation when set
    public var decimal: Bool {
        get { (self & 0b0000_1000) >> 3 == 1 }
        set {
            if newValue {
                self |= (1 << 3)
            } else {
                self &= ~(1 << 3)
            }
        }
    }

    // Intertupt disabled flag:
    // irq is ignored when set
    public var interrupt: Bool {
        get { (self & 0b0000_0100) >> 2 == 1 }
        set {
            if newValue {
                self |= (1 << 2)
            } else {
                self &= ~(1 << 2)
            }
        }
    }

    // Zero flag: result of last operation is zero
    public var zero: Bool {
        get { (self & 0b0000_0010) >> 1 == 1 }
        set {
            if newValue {
                self |= (1 << 1)
            } else {
                self &= ~(1 << 1)
            }
        }
    }

    // Carry flag: result of last operation
    // produced carry bit
    public var carry: Bool {
        get { (self & 0b0000_0001) == 1 }
        set {
            if newValue {
                self |= (1 << 0)
            } else {
                self &= ~(1 << 0)
            }
        }
    }
}

extension Array {
    fileprivate mutating func assign(at range: ClosedRange<Int>, _ value: [Element?]) throws {
        guard range.count == value.count else {
            throw EmulatorError.deviceError(
                "Device emittable addresses [\(range)] are not compatible with ram [0..65535]"
            )
        }
        for i in range {
            if let value = value[i - range.lowerBound] {
                self[i] = value
            }
        }
    }
}
