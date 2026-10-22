import i6502Assembler
import i6502Emulator
import QuartzCore
import SwiftUI

@Observable
final class EmulationEngine: @unchecked Sendable {
    private(set) var frameMs: Double = 0
    private(set) var screenImage: CGImage?

    private var emulator: Emulator

    // 341 dots × 262 scanlines = 89342 PPU cycles
    // 1 emulator cycle = 1 CPU + 3 PPU -> 89342 / 3 = 29781
    private let cyclesPerFrame = 29_781

    private let queue = DispatchQueue(label: "EmulationEngineQueue", qos: .userInteractive)
    private var timer: DispatchSourceTimer?

    var pressedButtons: Emulator.NESButton = []

    // TODO: support loading ROM's from Finder prompt
    private static func loadBundledROM(named name: String = "legally_obtained_game") -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: "nes") else {
            fatalError("ROM '\(name).nes' not found in app bundle")
        }
        return try! Data(contentsOf: url)
    }

    init() {
        emulator = Emulator(rom: Self.loadBundledROM())
    }

    func boot(memory: [UInt8?]) {
        queue.async { [self] in
            emulator = Emulator(rom: Self.loadBundledROM())
            emulator.reset()
            startLoop()
        }
    }

    func pressButton(_ button: Emulator.NESButton) {
        pressedButtons.insert(button)
        emulator.setController(pressedButtons)
    }

    func releaseButton(_ button: Emulator.NESButton) {
        pressedButtons.remove(button)
        emulator.setController(pressedButtons)
    }

    func reset() {
        queue.async { [self] in emulator.reset() }
    }

    func pressKey(_ key: UInt8?) {
        emulator.write(key, at: 0xFF)
    }

    func startLoop() {
        stopLoop()

        // aiming to match 60FPS which is 1/60 sec per frame = 16639267ns
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .nanoseconds(16_639_267), leeway: .milliseconds(1))
        timer.setEventHandler { [self] in
            let start = CACurrentMediaTime()
            emulator.setController(pressedButtons)
            for _ in 0 ..< cyclesPerFrame {
                emulator.cycle()
            }
            let elapsed = CACurrentMediaTime() - start
            let currentFrameMs = elapsed * 1000

            let fb = emulator.framebuffer()
            var pixels = fb
            let cgImage = CGContext(
                data: &pixels,
                width: 256, height: 240,
                bitsPerComponent: 8, bytesPerRow: 256 * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )?.makeImage()

            DispatchQueue.main.async { [self] in
                screenImage = cgImage
                frameMs = currentFrameMs
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
    private let engine: EmulationEngine

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

            ZStack {
                appTheme.palette.backgroundPrimary.ignoresSafeArea()
            }
            .overlay(alignment: .top) {
                if let image = engine.screenImage {
                    Image(image, scale: 1, label: Text("NES"))
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(256.0 / 240.0, contentMode: .fit)
                        .colorEffect(ShaderLibrary.scanlines(.float(3.0), .float(0.15)))
                        .distortionEffect(
                            ShaderLibrary.crtDistortion(.boundingRect, .float(0.04)),
                            maxSampleOffset: CGSize(width: 50, height: 50)
                        )
                }
            }
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f ms / 16 ms", engine.frameMs))
                }
                .font(.system(.title, design: .monospaced))
                .foregroundStyle(.green.opacity(0.8))
                .padding()
            }
            .overlay(alignment: .topLeading) {
                Circle().fill(.red).opacity(0.5).onTapGesture {
                    if let compiledProgram {
                        engine.boot(memory: compiledProgram)
                    }
                }
                .frame(width: 50)
                .padding()
            }
            .overlay(alignment: .bottom) {
                CapsuleButtonsView(
                    leftPressed: { engine.pressButton(.start) },
                    leftReleased: { engine.releaseButton([.start]) },
                    rightPressed: { engine.pressButton(.select) },
                    rightReleased: { engine.releaseButton([.select]) },
                )
                .frame(width: min(300, minSize / 4), height: min(75, minSize / 4))
            }
            .overlay(alignment: .bottomLeading) {
                DpadView(
                    onPress: { button in
                        engine.pressButton(button)
                    },
                    onRelease: {
                        engine.releaseButton([.up, .down, .left, .right])
                    }
                )
                .frame(width: min(300, minSize / 2), height: min(300, minSize / 2))
                .padding()
            }
            .overlay(alignment: .bottomTrailing) {
                CircleButtonsView(
                    leftPressed: { engine.pressButton(.a) },
                    leftReleased: { engine.releaseButton([.a]) },
                    rightPressed: { engine.pressButton(.b) },
                    rightReleased: { engine.releaseButton([.b]) }
                )
                .frame(width: minSize / 3, height: minSize / 4)
                .padding()
            }
        }
        .onDisappear { engine.stopLoop() }
        .onKeyPress(phases: .all) {
            if $0.key == .upArrow {
                if $0.phase == .down || $0.phase == .repeat{
                    engine.pressButton(.up)
                } else if $0.phase == .up {
                    engine.releaseButton([.up, .down, .left, .right])
                }
            }
            if $0.key == .downArrow {
                if $0.phase == .down || $0.phase == .repeat{
                    engine.pressButton(.down)
                } else if $0.phase == .up {
                    engine.releaseButton([.up, .down, .left, .right])
                }
            }
            if $0.key == .leftArrow {
                if $0.phase == .down || $0.phase == .repeat{
                    engine.pressButton(.left)
                } else if $0.phase == .up {
                    engine.releaseButton([.up, .down, .left, .right])
                }
            }

            if $0.key == .rightArrow {
                if $0.phase == .down || $0.phase == .repeat{
                    engine.pressButton(.right)
                } else if $0.phase == .up {
                    engine.releaseButton([.up, .down, .left, .right])
                }
            }

            return .handled
        }
    }
}
