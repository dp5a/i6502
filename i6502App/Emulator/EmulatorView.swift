import i6502Assembler
import i6502Emulator
import QuartzCore
import SwiftUI

@Observable
final class EmulationEngine: @unchecked Sendable {
    private(set) var monitor: [UInt8] = Array(repeating: 0, count: 1_024)
    private(set) var mhz: Double = 0
    private(set) var frameMs: Double = 0

    private var emulator: Emulator
    private let cyclesPerFrame = 35_736

    private let queue = DispatchQueue(label: "EmulationEngineQueue", qos: .userInteractive)
    private var timer: DispatchSourceTimer?

    init() {
        emulator = Emulator()
    }

    func boot(memory: [UInt8?]) {
        queue.async { [self] in
            emulator = Emulator()
            emulator.write(memory: memory)
            emulator.reset()
            startLoop()
        }
    }

    func reset() {
        queue.async { [self] in emulator.reset() }
    }

    func pressKey(_ key: UInt8?) {
        emulator.write(key, at: 0xFF)
    }

    func startLoop() {
        stopLoop()

        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(16), leeway: .milliseconds(1))
        timer.setEventHandler { [self] in
            let start = CACurrentMediaTime()
            for _ in 0 ..< cyclesPerFrame {
                emulator.cycle()
            }
            let elapsed = CACurrentMediaTime() - start
            let currentMhz = elapsed > 0 ? Double(cyclesPerFrame) / elapsed / 1_000_000 : 0

            let newMonitor = emulator.read(at: 0x200 ..< 0x600)
            DispatchQueue.main.async { [self] in
                monitor = newMonitor
                mhz = currentMhz
                frameMs = elapsed * 1_000
            }
        }
        timer.resume()

        self.timer = timer
    }

    func stopLoop() {
        timer?.cancel()
        timer = nil
    }
}

struct EmulatorView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark
    @State private var engine: EmulationEngine

    let codeStorage: CodeStorage

    var compiledProgram: Optional<[UInt8?]> {
        try? Assembler.compileBytes(input: codeStorage.code)
    }

    init(codeStorage: CodeStorage) {
        self.codeStorage = codeStorage
        engine = EmulationEngine()
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
                        let _ = timeline.date
                        for i in 0 ..< 1_024 {
                            let x = CGFloat(i % 32) * pixelSize
                            let y = CGFloat(i / 32) * pixelSize
                            let rect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)
                            let color: Color = engine.monitor[i] != 0
                                ? Color(red: 28 / 255, green: 206 / 255, blue: 29 / 255)
                                : Color(red: 2 / 255, green: 2 / 255, blue: 2 / 255)
                            context.fill(Path(rect), with: .color(color))
                        }
                    }
                    .frame(width: 32 * pixelSize, height: 32 * pixelSize)
                    .layerEffect(
                        ShaderLibrary.phosphorGlow(.float(8), .float(2.2)),
                        maxSampleOffset: CGSize(width: 10, height: 10)
                    )
                    .colorEffect(ShaderLibrary.scanlines(.float(8.0), .float(0.2)))
                    .distortionEffect(
                        ShaderLibrary.crtDistortion(.boundingRect, .float(0.04)),
                        maxSampleOffset: CGSize(width: 50, height: 50)
                    )
                }
            }
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f MHz / %.1f ms", engine.mhz, engine.frameMs))
                }
                .font(.system(.title, design: .monospaced))
                .foregroundStyle(.green.opacity(0.8))
                .padding()
            }
            .overlay(alignment: .bottomLeading) {
                DpadView { engine.pressKey($0) }
                    .frame(width: min(300, minSize / 2), height: min(300, minSize / 2))
                    .padding()
            }
            .overlay(alignment: .bottomTrailing) {
                ButtonsView(
                    reset: {
                        engine.reset()
                    },
                    action: {
                        if let compiledProgram {
                            engine.boot(memory: compiledProgram)
                        }
                    }
                )
                .frame(width: minSize / 3, height: minSize / 4)
                .padding()
            }
        }
        .onDisappear { engine.stopLoop() }
    }
}
