
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
                registerPC: 0,
                registerSP: 0,
                registerA: 0,
                registerX: 0,
                registerY: 0,
                registerPS: 0,
                memory: Array(repeating: 0, count: 65_536)
            )
        }
    }

    public typealias ProcessorStatus = UInt8
}

extension Emulator.ProcessorStatus {
    public var negative: Bool {
        get { (self & (1 << 7)) == 1 }
        set { self = self | (1 << 7) }
    }

    public var overflow: Bool {
        get { (self & (1 << 6)) == 1 }
        set { self = self | (1 << 6) }
    }

    public var skip: Bool { true }

    public var `break`: Bool {
        get { (self & (1 << 4)) == 1 }
        set { self = self | (1 << 4) }
    }

    public var decimal: Bool {
        get { (self & (1 << 3)) == 1 }
        set { self = self | (1 << 3) }
    }

    public var interrupt: Bool {
        get { (self & (1 << 3)) == 1 }
        set { self = self | (1 << 2) }
    }

    public var zero: Bool {
        get { (self & (1 << 3)) == 1 }
        set { self = self | (1 << 1) }
    }

    public var carry: Bool {
        get { (self & (1 << 3)) == 1 }
        set { self = self | 1 }
    }
}
