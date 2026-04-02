import i6502Assembler
import SwiftUI

struct EditorView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark
    @AppStorage("FontSize") private var fontSize: Double = 14
    @State private var onSettings: Bool = false

    @State private var _text: AttributedString?
    @State private var showInspector: Bool = true

    @Binding private var savedCode: String

    init(code: Binding<String>) {
        _savedCode = code
        _text = applyHighlighting(AttributedString(code.wrappedValue))
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            TextEditor(text: .init(
                get: { _text ?? "" },
                set: {
                    _text = applyHighlighting($0)
                    savedCode = String($0.characters)
                }
            ))
            .autocorrectionDisabled()
            .keyboardIOSSpecific()

            if showInspector, UIDevice.current.userInterfaceIdiom != .phone {
                HexdumpOverlayView(originalText: String(_text?.characters ?? .init()))
                    .transition(.move(edge: .trailing))
                    .padding([.trailing, .bottom], 12)
                    .ignoresSafeArea(.all, edges: [.trailing, .bottom])
                    .simultaneousGesture(DragGesture().onEnded {
                        if $0.predictedEndTranslation.width > 250 {
                            withAnimation {
                                showInspector = false
                            }
                        }
                    })
            }
        }
        .background(appTheme.palette.backgroundPrimary.ignoresSafeArea())
        .font(.system(size: fontSize, design: .monospaced))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Hexdump", systemImage: "sidebar.squares.trailing") {
                    withAnimation {
                        showInspector.toggle()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu("", systemImage: "ellipsis") {
                    Button("Settings", systemImage: "gear") { onSettings = true }
                    Divider()
                    Button("Import as..", systemImage: "square.and.arrow.down") {}
                    Button("Export as..", systemImage: "square.and.arrow.up") {}
                    Divider()
                    Button("About", systemImage: "info.circle") {}
                }
            }
        }
        .settingsSheet(isPresented: $onSettings)
        .onChange(of: appTheme) {
            _text = applyHighlighting(_text ?? "")
        }
    }

    private func applyHighlighting(_ string: AttributedString) -> AttributedString {
        var newText = string
        newText.foregroundColor = appTheme.palette.foregroundPrimary
        return newText
            .highlightingMatches(
                of: "\\.\\w*",
                color: appTheme.palette.directives
            )
            .highlightingMatches(
                of: "\\S*:",
                color: appTheme.palette.labels
            )
            .highlightingMatches(
                of: "\\$[0-9A-Fa-f]+",
                color: appTheme.palette.literals
            )
            .highlightingMatches(
                of: "\\b\\d+\\b",
                color: appTheme.palette.literals
            )
            .highlightingMatches(
                of: ";.*",
                color: appTheme.palette.comments
            )
    }
}

extension View {
    fileprivate func keyboardIOSSpecific() -> some View {
        self
        #if !os(macOS)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .scrollContentBackground(.hidden)
        #endif
    }
}

extension AttributedString {
    fileprivate func highlightingMatches(
        of pattern: String,
        color: Color = .blue,
        font: Font? = nil,
        backgroundColor: Color? = nil
    ) -> AttributedString {
        var result = self
        let text = String(result.characters)

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return result
        }

        let nsRange = NSRange(text.startIndex ..< text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: nsRange)

        for match in matches.reversed() { // Reverse to maintain indices
            if let range = Range(match.range, in: text),
               let attributedRange = Range(range, in: result)
            {
                result[attributedRange].foregroundColor = color
                if let font {
                    result[attributedRange].font = font
                }
                if let bgColor = backgroundColor {
                    result[attributedRange].backgroundColor = bgColor
                }
            }
        }

        return result
    }
}
