import i6502Emulator
import SwiftUI
import UIKit

// emits a random byte value
class RandomizerDevice: PluggableDevice {
    var irqRequired: Bool = false
    var nmiRequired: Bool = false

    var addresses: ClosedRange<Int> = 0xFE ... 0xFE
    var lastEmitted: UInt8 = 0

    func emit() -> [UInt8] {
        lastEmitted = UInt8.random(in: 0 ... 0xFF)
        return [lastEmitted]
    }

    func recieve(section: [UInt8]) {}
}

// emits an ASCII value of currently pressed key
class KeyboardDevice: PluggableDevice {
    var irqRequired: Bool = false
    var nmiRequired: Bool = false

    var addresses: ClosedRange<Int> = 0xFF ... 0xFF
    var pressed: UInt8? = nil

    func emit() -> [UInt8] {
        [pressed ?? 0]
    }

    func recieve(section: [UInt8]) {}
}

struct EmulatorView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark

    @State private var monitor: [UInt8]
    @State private var keyboard: KeyboardDevice
    @State private var randomizer: RandomizerDevice
    @State private var emulator: Emulator

    @State private var boot: Bool = false
    @State private var clock: Double = 0.7

    @State private var showInspector: Bool = false

    let cyclesPerFrame = 16_667 // 1 MHz
    let memory: [UInt8?]

    init(memory: [UInt8?]) {
        self.memory = memory

        monitor = Array(repeating: 0, count: 1_024)
        keyboard = KeyboardDevice()
        randomizer = RandomizerDevice()
        emulator = Emulator(
            emulationMode: .instructionAccurate,
            devices: [_randomizer.wrappedValue, _keyboard.wrappedValue]
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let minSize = min(proxy.size.width, proxy.size.height)
            let pixelSize = minSize / 32

            ZStack {
                appTheme.palette.backgroundPrimary.ignoresSafeArea()
            }
            .overlay(alignment: .top) {
                TimelineView(.animation) { timeline in
                    Canvas { context, _ in
                        for i in 0 ..< 1_024 {
                            let x = CGFloat(i % 32) * pixelSize
                            let y = CGFloat(i / 32) * pixelSize
                            let rect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)
                            let color: Color = monitor[i] != 0
                                ? Color(red: 28 / 255.0, green: 206 / 255.0, blue: 29 / 255.0)
                                : Color(red: 2 / 255.0, green: 2 / 255.0, blue: 2 / 255.0)

                            context
                                .fill(Path(rect), with: .color(color))
                        }
                    }
                    .frame(width: 32 * pixelSize, height: 32 * pixelSize)
                    .layerEffect(
                        ShaderLibrary.phosphorGlow(.float(8), .float(2.2)),
                        maxSampleOffset: CGSize(width: 10, height: 10)
                    )
                    .colorEffect(
                        ShaderLibrary.scanlines(.float(8.0), .float(0.2))
                    )
                    .distortionEffect(
                        ShaderLibrary.crtDistortion(.boundingRect, .float(0.04)),
                        maxSampleOffset: CGSize(width: 50, height: 50)
                    )
                    .onChange(of: timeline.date) {
                        if boot {
                            emulator = Emulator(
                                memory: memory,
                                emulationMode: .instructionAccurate,
                                devices: [randomizer, keyboard]
                            )
                            emulator.reset()
                            boot = false
                        } else {
                            // unthrottling CPU from 60Hz to 1MHz clock rate
                            for _ in 0 ..< cyclesPerFrame / 80 {
                                try? emulator.cycle()
                            }
                            // updating monitor only in 60Hz
                            monitor = Array(emulator.state.memory[0x200 ... 0x5FF])
                        }
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                DpadView { keyboard.pressed = $0 }
                    .frame(width: min(300, minSize / 2), height: min(300, minSize / 2))
                    .padding()
            }
            .overlay(alignment: .bottomTrailing) {
                ButtonsView(
                    reset: { emulator.reset() },
                    action: { boot = true }
                )
                .frame(width: minSize / 3, height: minSize / 4)
                .padding()
            }
        }
    }
}

#Preview {
    EmulatorView(memory: [])
}
