import SwiftUI

struct DpadView: View {
    @AppStorage("AppTheme") private var appTheme: AppTheme = .defaultDark

    @State private var pressPoint: CGPoint = .zero
    @State private var isPressed: Bool = false
    let onTap: (UInt8) -> Void

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let offsetX = isPressed ? (pressPoint.x - center.x) / center.x : 0
            let offsetY = isPressed ? (pressPoint.y - center.y) / center.y : 0

            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: proxy.size.width * 0.95)
                    .backgroundiOSSpecific()

                DpadShape()
                    .fill(appTheme.palette.backgroundPrimary)

                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: proxy.size.width / 3 * 0.85)

                Circle()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: proxy.size.width / 3 * 0.85)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(
                DpadShape()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
            .contentShape(DpadShape())
            .rotation3DEffect(
                .degrees(isPressed ? 6 : 0),
                axis: (x: -offsetY, y: offsetX, z: 0),
                perspective: 0.4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        pressPoint = value.location
                        isPressed = true

                        let third = proxy.size.width / 3

                        if (0 ... third).contains(value.location.y) {
                            onTap(0x77) // up
                        } else if (2 * third ... proxy.size.width).contains(value.location.x) {
                            onTap(0x64) // right
                        } else if (2 * third ... proxy.size.height).contains(value.location.y) {
                            onTap(0x73) // down
                        } else if (0 ... third).contains(value.location.x) {
                            onTap(0x61) // left
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
            .shadow(radius: 10)
        }
    }
}

#Preview {
    @Previewable @AppStorage("AppTheme") var appTheme: AppTheme = .defaultDark
    @Previewable @State var clockFrequency: Int = 2

    ZStack {
        appTheme.palette.backgroundPrimary.ignoresSafeArea()

        DpadView(onTap: { _ in })
            .frame(width: 400, height: 400)
        // .border(.red)
    }
}

struct DpadShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> DpadShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()
        let radius: CGFloat = rect.width / 24

        path.move(to: CGPoint(
            x: r.midX,
            y: r.minY
        ))

        path.addLine(to: CGPoint(
            x: r.maxX - rect.width / 3 - radius,
            y: r.minY
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - rect.width / 3 - radius,
                y: r.minY + radius
            ),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.maxX - rect.width / 3,
            y: rect.width / 3 - radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - rect.width / 3 + radius,
                y: rect.width / 3 - radius
            ),
            radius: radius,
            startAngle: .degrees(-180),
            endAngle: .degrees(90),
            clockwise: true
        )

        path.addLine(to: CGPoint(
            x: r.maxX - radius,
            y: rect.width / 3
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - radius,
                y: rect.width / 3 + radius
            ),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.maxX,
            y: r.maxY - rect.width / 3 - radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - radius,
                y: r.maxY - rect.width / 3 - radius
            ),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(-270),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.maxX - rect.width / 3 + radius,
            y: r.maxY - rect.width / 3
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - rect.width / 3 + radius,
                y: r.maxY - rect.width / 3 + radius
            ),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-180),
            clockwise: true
        )

        path.addLine(to: CGPoint(
            x: r.maxX - rect.width / 3,
            y: r.maxY - radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.maxX - rect.width / 3 - radius,
                y: r.maxY - radius
            ),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.minX + rect.width / 3 + radius,
            y: r.maxY
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + rect.width / 3 + radius,
                y: r.maxY - radius
            ),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.minX + rect.width / 3,
            y: r.maxY - rect.width / 3 + radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + rect.width / 3 - radius,
                y: r.maxY - rect.width / 3 + radius
            ),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(270),
            clockwise: true
        )

        path.addLine(to: CGPoint(
            x: r.minX + radius,
            y: r.maxY - rect.width / 3
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + radius,
                y: r.maxY - rect.width / 3 - radius
            ),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.minX,
            y: r.minY + rect.width / 3 + radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + radius,
                y: r.minY + rect.width / 3 + radius
            ),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.addLine(to: CGPoint(
            x: r.minX + rect.width / 3 - radius,
            y: r.minY + rect.width / 3
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + rect.width / 3 - radius,
                y: r.minY + rect.width / 3 - radius
            ),
            radius: radius,
            startAngle: .degrees(-270),
            endAngle: .degrees(0),
            clockwise: true
        )

        path.addLine(to: CGPoint(
            x: r.minX + rect.width / 3,
            y: r.minY + radius
        ))

        path.addArc(
            center: CGPoint(
                x: r.minX + rect.width / 3 + radius,
                y: r.minY + radius
            ),
            radius: radius,
            startAngle: .degrees(-180),
            endAngle: .degrees(-90),
            clockwise: false
        )

        path.closeSubpath()
        return path
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
