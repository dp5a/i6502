
// Protocol for pluggable devices such as monitors, keyboards, randomizers etc.
public protocol PluggableDevice {
    // Device memory section start and end addresses
    var addresses: ClosedRange<Int> { get set }

    // Called at the start of CPU cycle and writes emitted values to assigned section
    func emit() -> [UInt8]

    // Called at the end of CPU cycle and recieves values from assigned section
    func recieve(section: [UInt8])
}

public enum EmulationMode {
    case instructionAccurate
    case cycleAccurate
}

public final class Emulator {
    public private(set) var emulationMode: EmulationMode
    public private(set) var state: StateImage = .init()
    public private(set) var devices: [PluggableDevice] = []
    private var remainingCycles: Int = 0

    public init(emulationMode: EmulationMode, devices: [PluggableDevice]) {
        self.emulationMode = emulationMode
        self.devices = devices
    }

    public func cycle() throws {
        switch emulationMode {
        case .instructionAccurate:
            try cycleInstructionAccurate()
        case .cycleAccurate:
            throw EmulatorError.unsupportedEmulationModeError(
                "Cycle-accurate emulation is not supported for now"
            )
        }
    }

    public func cycleInstructionAccurate() throws {
        var nextState = state

        // handle devices emits
        for device in devices {
            try nextState.memory.assign(at: device.addresses, device.emit())
        }

        // emulate operation timings
        if remainingCycles != 0 {
            remainingCycles = try nextState.cycleInstructionAccurate()
        }

        // handle devices recieves
        for device in devices {
            guard nextState.memory.indices.contains(device.addresses) else {
                throw EmulatorError.deviceError(
                    "Device recieving addresses [\(device.addresses)] are not compatible with ram [0..65535]"
                )
            }
            device.recieve(section: Array(nextState.memory[device.addresses]))
        }
    }
}

public enum EmulatorError: Error {
    case unsupportedEmulationModeError(String)
    case deviceError(String)
    case stateCycleError(String)
}

extension Array {
    fileprivate mutating func assign(at range: ClosedRange<Int>, _ value: Self) throws {
        guard [range].count == value.count else {
            throw EmulatorError.deviceError(
                "Device emittable addresses [\(range)] are not compatible with ram [0..65535]"
            )
        }
        for i in range {
            self[i] = value[i]
        }
    }
}
