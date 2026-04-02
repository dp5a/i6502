import SwiftUI

struct ButtonsView: View {
    let reset: () -> Void
    let action: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button {
                reset()
            } label: {}
                .buttonStyle(RedButtonStyle())

            Button {
                action()
            } label: {}
                .buttonStyle(RedButtonStyle())
        }
    }
}

private struct RedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Color(red: 157 / 255.0, green: 35 / 255.0, blue: 45 / 255.0)
            .opacity(0.8)
            .backgroundiOSSpecific()
            .contentShape(.circle)
            .clipShape(.circle)
            .overlay(Circle().strokeBorder(Color.white.opacity(0.2)))
            .scaleEffect(configuration.isPressed ? CGSize(width: 0.92, height: 0.92) : CGSize(width: 1, height: 1))
    }
}

#Preview {
    @Previewable @AppStorage("AppTheme") var appTheme: AppTheme = .defaultDark

    ZStack {
        appTheme.palette.backgroundPrimary.ignoresSafeArea()

        ButtonsView(reset: {}, action: {})
            .border(.red)
    }
}

extension View {
    fileprivate func backgroundiOSSpecific() -> some View {
        self
        #if !os(macOS)
        .background(
            VisualEffectView(effect: UIBlurEffect.withRadius(3))
                .clipShape(Circle())
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
