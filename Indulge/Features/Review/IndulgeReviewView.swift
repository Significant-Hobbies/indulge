import RealityKit
import SwiftUI
import UIKit

struct IndulgeReviewView: View {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    @State private var selectedIndulgence: IndulgenceID
    @State private var assembly: SceneAssemblyStage
    @State private var companion: CompanionID?
    @State private var possibleProgress: Double
    @State private var replayToken: Int
    @State private var forceReduceMotion: Bool
    @State private var ambientPulse: Float = 0
    @State private var selectedBeat: ReviewBeat

    init(preset: ReviewPreset = .launchArguments) {
        let autoPlay = preset == .standard || preset == .reduced
        let progress: Double = switch preset {
        case .possible, .replacement, .graduation: 1
        case .history: 0.72
        default: 0
        }
        _selectedIndulgence = State(initialValue: .television)
        _assembly = State(initialValue: autoPlay ? .standing : .settled)
        _companion = State(initialValue: preset == .wine ? .wineGlass : nil)
        _possibleProgress = State(initialValue: progress)
        _replayToken = State(initialValue: autoPlay ? 1 : 0)
        _forceReduceMotion = State(initialValue: preset == .reduced)
        _selectedBeat = State(initialValue: preset.reviewBeat)
    }

    private var recipe: IndulgenceRecipe {
        IndulgenceCatalog.byID[selectedIndulgence] ?? IndulgenceCatalog.recipes[0]
    }

    private var reduceMotion: Bool {
        systemReduceMotion || forceReduceMotion
    }

    private var sceneSummary: String {
        SoftFormScene.semanticSummary(
            assembly: assembly,
            companion: companion,
            possibleProgress: possibleProgress
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                stageBackground

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 22)
                        .padding(.top, 8)

                    scene
                        .frame(maxHeight: max(330, proxy.size.height * 0.54))
                        .padding(.horizontal, 2)

                    actionPanel
                        .padding(.horizontal, 14)
                        .padding(.bottom, max(8, proxy.safeAreaInsets.bottom))
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .task(id: replayToken) {
            guard replayToken > 0 else { return }
            await playSelectedBeat()
        }
        .task(id: assembly) {
            await runAmbientLoopIfSettled()
        }
        .onChange(of: selectedIndulgence) {
            companion = recipe.defaultCompanions.first
            possibleProgress = 0
            replayToken += 1
        }
    }

    private var stageBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .indulgeForest, location: 0),
                .init(color: .indulgeTeal, location: 0.54),
                .init(color: .indulgeNight, location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.indulgeSun.opacity(0.15))
                .frame(width: 280, height: 280)
                .blur(radius: 38)
                .offset(x: 100, y: -100)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("INDULGE")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(Color.indulgeCream)
                Text("Enjoy on purpose.")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()

            Button {
                forceReduceMotion.toggle()
                replayToken += 1
            } label: {
                Label(
                    reduceMotion ? "Reduced motion" : "Full motion",
                    systemImage: reduceMotion ? "figure.walk.motion" : "sparkles"
                )
                .labelStyle(.iconOnly)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.10), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
            }
            .foregroundStyle(.white)
            .accessibilityLabel(reduceMotion ? "Use full motion" : "Use reduced motion")

            Menu {
                ForEach(ReviewBeat.allCases, id: \.self) { beat in
                    Button {
                        selectedBeat = beat
                        replayToken += 1
                    } label: {
                        Label(beat.title, systemImage: beat.icon)
                    }
                }
            } label: {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.10), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
            }
            .foregroundStyle(.white)
            .accessibilityLabel("Choose animation: \(selectedBeat.title)")
        }
    }

    private var scene: some View {
        RealityView { content in
            content.add(SoftFormScene.makeRoot())
        } update: { content in
            guard let root = content.entities.first(where: { $0.name == SoftFormScene.rootName }) else {
                return
            }
            SoftFormScene.apply(
                root: root,
                assembly: assembly,
                companion: companion,
                possibleProgress: possibleProgress,
                reduceMotion: reduceMotion,
                animated: true,
                ambientPulse: ambientPulse
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your Habits scene")
        .accessibilityValue(sceneSummary)
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(possibleProgress > 0.55 ? "A little more room for life" : "This is where your time goes")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(recipe.familyLabel + " · " + recipe.basePose.displayName)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer(minLength: 4)

                Menu {
                    ForEach(IndulgenceCatalog.recipes, id: \.id) { option in
                        Button(option.title) {
                            selectedIndulgence = option.id
                        }
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "tv.fill")
                        Text(recipe.title)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .background(Color.white.opacity(0.10), in: Capsule())
                }
                .foregroundStyle(.white)
                .accessibilityLabel("Selected indulgence: \(recipe.title)")
            }

            possibleScrubber

            companionTray

            Button {
                replayToken += 1
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Replay \(selectedBeat.shortTitle)")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(.body, design: .rounded, weight: .bold))
                .padding(.horizontal, 17)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    LinearGradient(colors: [.indulgeCream, .indulgeSun], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                )
                .foregroundStyle(Color.indulgeInk)
            }
            .accessibilityHint("Plays the selected scene transformation")
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.indulgeForest.opacity(colorSchemeContrast == .increased ? 0.98 : 0.88))
                .shadow(color: .black.opacity(0.23), radius: 24, y: 10)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(colorSchemeContrast == .increased ? 0.28 : 0.10), lineWidth: 1)
        }
    }

    private var possibleScrubber: some View {
        VStack(spacing: 5) {
            HStack {
                Label("Now", systemImage: differentiateWithoutColor ? "circle.fill" : "circle")
                Spacer()
                Text("Make room")
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                Label("Possible", systemImage: differentiateWithoutColor ? "sun.max.fill" : "sparkles")
            }
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(.white.opacity(0.82))

            Slider(value: $possibleProgress, in: 0...1)
                .tint(Color.indulgeSun)
                .frame(minHeight: 44)
                .accessibilityLabel("Life possibility")
                .accessibilityValue("\(Int(possibleProgress * 100)) percent")
        }
    }

    private var companionTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                companionChip(nil, title: "Just this", icon: "person.fill")
                companionChip(.mug, title: "Coffee", icon: "mug.fill")
                companionChip(.wineGlass, title: "Wine", icon: "wineglass.fill")
                companionChip(.smoking, title: "Smoke", icon: "smoke.fill")
                companionChip(.phone, title: "Phone", icon: "iphone")
            }
            .padding(.horizontal, 1)
        }
        .accessibilityLabel("Add something to the scene")
    }

    private func companionChip(_ id: CompanionID?, title: String, icon: String) -> some View {
        let selected = companion == id
        return Button {
            companion = id
            confirmationHaptic()
        } label: {
            Label(title, systemImage: selected && differentiateWithoutColor ? "checkmark.circle.fill" : icon)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .padding(.horizontal, 13)
                .frame(minHeight: 44)
                .background(
                    selected ? Color.white.opacity(0.19) : Color.white.opacity(0.07),
                    in: Capsule()
                )
                .overlay {
                    Capsule().stroke(selected ? Color.white.opacity(0.58) : .white.opacity(0.09), lineWidth: 1)
                }
        }
        .foregroundStyle(.white)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityHint(id?.explicitOnly == true ? "Adds only the choice you selected; Habits never recommends it" : "Adds this item to the character")
    }

    @MainActor
    private func playSelectedBeat() async {
        switch selectedBeat {
        case .presentLife:
            await playPresentLifeSequence()
        case .watching:
            await playWatchingSequence()
        case .trade:
            await playTradeSequence()
        case .replacement:
            await playReplacementSequence()
        case .history:
            await playHistorySequence()
        case .graduation:
            await playGraduationSequence()
        }
    }

    @MainActor
    private func playWatchingSequence() async {
        companion = nil
        possibleProgress = 0
        assembly = .standing

        if reduceMotion {
            for step in [SceneAssemblyStage.stageArrived, .sofaArrived, .seated, .televisionArrived, .settled] {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(180))
                withAnimation(.easeInOut(duration: 0.16)) {
                    assembly = step
                }
            }
            return
        }

        try? await Task.sleep(for: .milliseconds(260))
        guard !Task.isCancelled else { return }
        withAnimation(.spring(duration: 0.55, bounce: 0.34)) { assembly = .stageArrived }

        try? await Task.sleep(for: .milliseconds(520))
        guard !Task.isCancelled else { return }
        withAnimation(.spring(duration: 0.70, bounce: 0.28)) { assembly = .sofaArrived }

        try? await Task.sleep(for: .milliseconds(680))
        guard !Task.isCancelled else { return }
        withAnimation(.smooth(duration: 0.60)) { assembly = .seated }
        selectionHaptic()

        try? await Task.sleep(for: .milliseconds(580))
        guard !Task.isCancelled else { return }
        withAnimation(.spring(duration: 0.62, bounce: 0.25)) { assembly = .televisionArrived }

        try? await Task.sleep(for: .milliseconds(560))
        guard !Task.isCancelled else { return }
        withAnimation(.spring(duration: 0.55, bounce: 0.20)) { assembly = .settled }
        confirmationHaptic()
    }

    @MainActor
    private func playPresentLifeSequence() async {
        assembly = .standing
        companion = nil
        possibleProgress = 0
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 160 : 420))
        guard !Task.isCancelled else { return }
        withAnimation(reduceMotion ? .easeInOut(duration: 0.16) : .spring(duration: 0.58, bounce: 0.24)) {
            companion = .phone
        }
        selectionHaptic()
    }

    @MainActor
    private func playTradeSequence() async {
        assembly = .televisionArrived
        possibleProgress = 0
        companion = .phone
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 180 : 620))
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: reduceMotion ? 0.18 : 0.48)) {
            companion = .mug
            possibleProgress = 0.34
        }
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 160 : 520))
        guard !Task.isCancelled else { return }
        assembly = .settled
        confirmationHaptic()
    }

    @MainActor
    private func playReplacementSequence() async {
        assembly = .televisionArrived
        possibleProgress = 0
        companion = .phone
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 160 : 500))
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: reduceMotion ? 0.20 : 1.15)) {
            companion = nil
            possibleProgress = 1
        }
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 220 : 900))
        guard !Task.isCancelled else { return }
        assembly = .settled
        confirmationHaptic()
    }

    @MainActor
    private func playHistorySequence() async {
        assembly = .televisionArrived
        companion = nil
        possibleProgress = 0.12
        let values = [0.30, 0.52, 0.74, 0.90]
        for value in values {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 150 : 360))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: reduceMotion ? 0.15 : 0.40)) {
                possibleProgress = value
            }
        }
        assembly = .settled
        confirmationHaptic()
    }

    @MainActor
    private func playGraduationSequence() async {
        assembly = .televisionArrived
        companion = nil
        possibleProgress = 0.68
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 180 : 620))
        guard !Task.isCancelled else { return }
        withAnimation(.easeInOut(duration: reduceMotion ? 0.20 : 1.05)) {
            possibleProgress = 1
        }
        try? await Task.sleep(for: .milliseconds(reduceMotion ? 220 : 820))
        guard !Task.isCancelled else { return }
        assembly = .settled
        confirmationHaptic()
    }

    private func selectionHaptic() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func confirmationHaptic() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.72)
    }

    @MainActor
    private func runAmbientLoopIfSettled() async {
        ambientPulse = 0
        guard assembly == .settled, !reduceMotion else { return }

        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 1.8)) { ambientPulse = 1 }
            try? await Task.sleep(for: .milliseconds(1_800))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 1.8)) { ambientPulse = 0 }
            try? await Task.sleep(for: .milliseconds(1_800))
        }
    }
}

private extension CharacterPose {
    var displayName: String {
        switch self {
        case .standing: "Standing"
        case .sofaSeated: "Sofa scene"
        case .chairSeated: "Desk scene"
        case .reclined: "Resting scene"
        case .crossLegged: "Floor scene"
        }
    }
}

#Preview("Watching with wine") {
    IndulgeReviewView(preset: .wine)
}

enum ReviewPreset {
    case standard
    case wine
    case possible
    case reduced
    case replacement
    case history
    case graduation

    static var launchArguments: ReviewPreset {
        if ProcessInfo.processInfo.arguments.contains("--possible") { return .possible }
        if ProcessInfo.processInfo.arguments.contains("--wine") { return .wine }
        if ProcessInfo.processInfo.arguments.contains("--reduce-motion") { return .reduced }
        if ProcessInfo.processInfo.arguments.contains("--replacement") { return .replacement }
        if ProcessInfo.processInfo.arguments.contains("--history") { return .history }
        if ProcessInfo.processInfo.arguments.contains("--graduation") { return .graduation }
        return .standard
    }

    var reviewBeat: ReviewBeat {
        switch self {
        case .replacement: .replacement
        case .history: .history
        case .graduation: .graduation
        default: .watching
        }
    }
}

enum ReviewBeat: String, CaseIterable {
    case presentLife
    case watching
    case trade
    case replacement
    case history
    case graduation

    var title: String {
        switch self {
        case .presentLife: "Present-life reveal"
        case .watching: "Watching assembles"
        case .trade: "Trade transform"
        case .replacement: "Replacement completes"
        case .history: "Weekly world morph"
        case .graduation: "Graduation"
        }
    }

    var shortTitle: String {
        switch self {
        case .presentLife: "the reveal"
        case .watching: "how it appears"
        case .trade: "the trade"
        case .replacement: "the replacement"
        case .history: "the week"
        case .graduation: "graduation"
        }
    }

    var icon: String {
        switch self {
        case .presentLife: "apps.iphone"
        case .watching: "sofa.fill"
        case .trade: "arrow.triangle.2.circlepath"
        case .replacement: "sparkles.rectangle.stack"
        case .history: "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .graduation: "door.left.hand.open"
        }
    }
}

#Preview("Possible life") {
    IndulgeReviewView(preset: .possible)
}

#Preview("Reduce Motion") {
    IndulgeReviewView(preset: .reduced)
}

#Preview("Completed replacement") {
    IndulgeReviewView(preset: .replacement)
}

#Preview("History morph") {
    IndulgeReviewView(preset: .history)
}

#Preview("Graduation") {
    IndulgeReviewView(preset: .graduation)
}
