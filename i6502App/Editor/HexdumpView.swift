import i6502Assembler
import SwiftUI

#if !os(macOS)
import UIKit
#endif

struct HexdumpOverlayView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark
    let originalText: String

    var body: some View {
        HexdumpView(originalText: originalText)
            .frame(width: 500, alignment: .topLeading)
            .backgroundiOSSpecific()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
            .clipped()
            .shadow(radius: 10)
    }
}

struct HexdumpTabView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark
    let originalText: String

    var body: some View {
        HexdumpView(originalText: originalText)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(appTheme.palette.backgroundPrimary.ignoresSafeArea())
    }
}

private struct HexdumpView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark
    @AppStorage("FontSize") private var fontSize: Double = 14
    @State private var rowSize: Int = 16
    let originalText: String

    private var hexdumpRepresentation: AttributedString {
        do {
            let result = try hexDump(Assembler.compileBytes(input: originalText), rowSize: rowSize)
            if result.characters.isEmpty {
                return "Enter operations to start"
            }
            return result
        } catch let AssemblerError.linkerError(description) {
            return AttributedString("Linker error: \(description)")
        } catch let AssemblerError.tokenizerError(description) {
            return AttributedString("Tokenizer error: \(description)")
        } catch let AssemblerError.translatorError(description) {
            return AttributedString("Translator error: \(description)")
        } catch {
            return AttributedString("Unknown error!")
        }
    }

    var body: some View {
        ScrollView {
            Text(hexdumpRepresentation)
                .padding()
                .font(.system(size: fontSize, design: .monospaced))
                .foregroundStyle(appTheme.palette.foregroundPrimary)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .onAppear {
            updateRowSize(fontSize)
        }
        .onChange(of: fontSize) {
            updateRowSize(fontSize)
        }
    }

    private func updateRowSize(_ fontSize: Double) {
        if fontSize > 17 {
            rowSize = 8
        } else {
            rowSize = 16
        }
    }

    private func hexDump(_ bytes: [UInt8?], rowSize: Int) -> AttributedString {
        var result = ""
        for (rowIndex, row) in bytes.chunked(into: 16).enumerated() {
            if !row.allSatisfy({ $0 == nil }) {
                result += String(format: "%.4x: ", rowIndex * 16)
                for col in row {
                    if let col {
                        result += String(format: "%.2x ", col)
                    } else {
                        result += "** "
                    }
                }
                result += "\n"
            }
        }
        return AttributedString(result)
    }
}

extension View {
    fileprivate func backgroundiOSSpecific() -> some View {
        self
        #if !os(macOS)
        .background(
            VisualEffectView(effect: UIBlurEffect.withRadius(3))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
        #endif
    }
}

#if !os(macOS)
private struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    init(effect: UIVisualEffect?) {
        self.effect = effect
    }

    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}

@objc private protocol UIBlurEffectWithRadius {
    func effect(withBlurRadius: Double) -> Self?
}

extension UIBlurEffect {
    fileprivate static func withRadius(_ radius: Double) -> UIBlurEffect? {
        if UIBlurEffect.responds(to: #selector(UIBlurEffectWithRadius.effect(withBlurRadius:))) {
            return UIBlurEffect.perform(#selector(UIBlurEffectWithRadius.effect(withBlurRadius:)))
                .takeUnretainedValue() as? UIBlurEffect
        }

        return nil
    }
}
#endif

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
