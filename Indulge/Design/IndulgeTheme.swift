import SwiftUI
import UIKit

enum IndulgeTheme {
    static let cornerRadius: CGFloat = 16
    static let panelCornerRadius: CGFloat = 28

    static let ambientMesh = MeshGradient(
        width: 3,
        height: 3,
        points: [
            [0, 0], [0.50, 0], [1, 0],
            [0, 0.48], [0.52, 0.42], [1, 0.55],
            [0, 1], [0.48, 1], [1, 1]
        ],
        colors: [
            .indulgeNight, .indulgeDusk, .indulgeNight,
            .indulgeForest, .indulgeTeal, .indulgeAubergine,
            .indulgeNight, .indulgeClay, .indulgeNight
        ],
        background: .indulgeNight,
        smoothsColors: true
    )
}

extension Color {
    static let indulgePowder = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.075, green: 0.16, blue: 0.23, alpha: 1)
            : UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
    })
    static let indulgePowderSoft = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.035, green: 0.095, blue: 0.14, alpha: 1)
            : UIColor(red: 0.95, green: 0.98, blue: 1.00, alpha: 1)
    })
    static let indulgeCherry = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.00, green: 0.34, blue: 0.42, alpha: 1)
            : UIColor(red: 0.86, green: 0.16, blue: 0.23, alpha: 1)
    })
    static let indulgeNavy = Color(red: 0.045, green: 0.11, blue: 0.22)
    static let indulgePaleBorder = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.35, blue: 0.46, alpha: 1)
            : UIColor(red: 0.72, green: 0.82, blue: 0.93, alpha: 1)
    })
    static let indulgeSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.018, green: 0.055, blue: 0.085, alpha: 1)
            : .white
    })
    static let indulgeText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.92, green: 0.96, blue: 1.00, alpha: 1)
            : UIColor(red: 0.045, green: 0.11, blue: 0.22, alpha: 1)
    })
    static let indulgeNight = Color(red: 0.018, green: 0.063, blue: 0.070)
    static let indulgeForest = Color(red: 0.035, green: 0.20, blue: 0.19)
    static let indulgeTeal = Color(red: 0.09, green: 0.40, blue: 0.37)
    static let indulgeDusk = Color(red: 0.16, green: 0.12, blue: 0.21)
    static let indulgeAubergine = Color(red: 0.25, green: 0.12, blue: 0.20)
    static let indulgeClay = Color(red: 0.27, green: 0.16, blue: 0.14)
    static let indulgeMint = Color(red: 0.48, green: 0.78, blue: 0.64)
    static let indulgeLilac = Color(red: 0.61, green: 0.49, blue: 0.80)
    static let indulgeCream = Color(red: 0.98, green: 0.89, blue: 0.70)
    static let indulgeSun = Color(red: 0.96, green: 0.71, blue: 0.35)
    static let indulgePeach = Color(red: 0.94, green: 0.57, blue: 0.42)
    static let indulgeInk = Color(red: 0.055, green: 0.12, blue: 0.12)
    static let indulgeOnboardingPanel = Color(red: 0.105, green: 0.082, blue: 0.135)
    static let indulgeOnboardingAccent = Color(red: 0.78, green: 0.70, blue: 0.88)
    static let indulgeOnboardingAction = Color(red: 0.92, green: 0.90, blue: 0.94)
    static let indulgeOnboardingInk = Color(red: 0.12, green: 0.085, blue: 0.15)
    static let indulgeChoice = Color.white.opacity(0.065)
    static let indulgeChoiceSelected = Color.indulgeOnboardingAccent.opacity(0.18)
}

extension Font {
    static let indulgeWordmark = Font.system(.caption, design: .rounded, weight: .heavy)
    static let indulgeDisplay = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let indulgeQuestion = Font.system(.title2, design: .rounded, weight: .bold)
    static let indulgeTitle = Font.system(.title3, design: .rounded, weight: .bold)
    static let indulgeBody = Font.body
    static let indulgeControl = Font.system(.body, design: .default, weight: .semibold)
    static let indulgeLabel = Font.system(.subheadline, design: .default, weight: .semibold)
    static let indulgeCaption = Font.system(.caption, design: .default, weight: .medium)
}

struct IndulgeAmbientBackdrop: View {
    var body: some View {
        IndulgeTheme.ambientMesh
            .overlay(Color.indulgeNight.opacity(0.20))
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

struct IndulgePressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .brightness(configuration.isPressed ? -0.035 : 0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct IndulgeGlassControlModifier<S: Shape>: ViewModifier {
    let shape: S

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.12), lineWidth: 1))
        }
    }
}

extension View {
    func indulgeGlassControl<S: Shape>(in shape: S) -> some View {
        modifier(IndulgeGlassControlModifier(shape: shape))
    }
}
