import Foundation

enum HeroTransition: String, CaseIterable, Sendable {
    case presentLife
    case assembleWatching
    case scrubPossible
    case completeReplacement
    case morphWeek
    case graduate
}

enum TransitionPresentation: String, Sendable {
    case depthArrival
    case characterResponse
    case inPlaceCrossfade
    case continuousInterpolation
    case settle
}

struct TransitionBeat: Equatable, Sendable {
    let name: String
    let duration: TimeInterval
    let presentation: TransitionPresentation
}

struct SceneTransitionPlan: Equatable, Sendable {
    let transition: HeroTransition
    let beats: [TransitionBeat]
    let pausesAmbientMotion: Bool

    var totalDuration: TimeInterval {
        beats.reduce(0) { $0 + $1.duration }
    }
}

enum SceneTransitionCatalog {
    static func plan(for transition: HeroTransition, reduceMotion: Bool) -> SceneTransitionPlan {
        if reduceMotion {
            return SceneTransitionPlan(
                transition: transition,
                beats: reducedBeats(for: transition),
                pausesAmbientMotion: true
            )
        }

        return SceneTransitionPlan(
            transition: transition,
            beats: standardBeats(for: transition),
            pausesAmbientMotion: true
        )
    }

    private static func standardBeats(for transition: HeroTransition) -> [TransitionBeat] {
        switch transition {
        case .presentLife:
            [beat("apps gather", 0.42, .depthArrival), beat("character notices", 0.36, .characterResponse), beat("settle", 0.24, .settle)]
        case .assembleWatching:
            [beat("stage", 0.38, .depthArrival), beat("sofa", 0.62, .depthArrival), beat("sit", 0.56, .characterResponse), beat("television", 0.52, .depthArrival), beat("lamp", 0.40, .settle)]
        case .scrubPossible:
            [beat("now to possible", 0, .continuousInterpolation)]
        case .completeReplacement:
            [beat("trade turns", 0.34, .characterResponse), beat("replacement arrives", 0.58, .depthArrival), beat("confirm", 0.24, .settle)]
        case .morphWeek:
            [beat("week arcs", 0.44, .depthArrival), beat("world grows", 0.64, .continuousInterpolation), beat("settle", 0.24, .settle)]
        case .graduate:
            [beat("boundary opens", 0.52, .depthArrival), beat("character steps through", 0.72, .characterResponse), beat("quiet finish", 0.30, .settle)]
        }
    }

    private static func reducedBeats(for transition: HeroTransition) -> [TransitionBeat] {
        switch transition {
        case .scrubPossible:
            [beat("now details fade", 0.16, .inPlaceCrossfade), beat("possible details appear", 0.16, .inPlaceCrossfade)]
        default:
            [beat("current state fades", 0.14, .inPlaceCrossfade), beat("next state appears", 0.18, .inPlaceCrossfade), beat("confirm", 0.10, .settle)]
        }
    }

    private static func beat(
        _ name: String,
        _ duration: TimeInterval,
        _ presentation: TransitionPresentation
    ) -> TransitionBeat {
        TransitionBeat(name: name, duration: duration, presentation: presentation)
    }
}

struct TransitionGeneration: Equatable, Sendable {
    private(set) var value = 0

    mutating func begin() -> Int {
        value += 1
        return value
    }

    func isCurrent(_ candidate: Int) -> Bool {
        value == candidate
    }
}
