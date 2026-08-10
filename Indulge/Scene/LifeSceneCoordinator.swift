import Foundation

struct SceneComposition: Equatable, Sendable {
    let assembly: SceneAssemblyStage
    let companion: CompanionID?
    let possibleProgress: Double
    let semanticSummary: String
}

enum LifeSceneCoordinator {
    static func composition(for state: LifeSceneState) -> SceneComposition {
        let assembly: SceneAssemblyStage = switch state.phase {
        case .presentLife: .standing
        case .assembling: .sofaArrived
        case .settled, .exploringPossible, .replacementComplete, .history, .graduation: .settled
        }

        let progress: Double = switch state.phase {
        case .replacementComplete, .graduation: 1
        case .history: max(state.possibleProgress, min(Double(state.historyWeek) / 6, 1))
        default: state.possibleProgress
        }

        return SceneComposition(
            assembly: assembly,
            companion: state.companion,
            possibleProgress: progress,
            semanticSummary: semanticSummary(
                assembly: assembly,
                companion: state.companion,
                progress: progress,
                phase: state.phase
            )
        )
    }

    private static func semanticSummary(
        assembly: SceneAssemblyStage,
        companion: CompanionID?,
        progress: Double,
        phase: ScenePhase
    ) -> String {
        if phase == .graduation {
            return "Your character steps beyond the old boundary into a fuller, self-directed life."
        }
        if phase == .history {
            return "The same world has grown across recent weeks as reclaimed time becomes visible."
        }
        return SoftFormScene.semanticSummary(
            assembly: assembly,
            companion: companion,
            possibleProgress: progress
        )
    }
}
