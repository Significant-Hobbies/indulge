import Foundation

enum IndulgenceID: String, CaseIterable, Codable, Hashable, Sendable {
    case television
    case streaming
    case films
    case shortVideo
    case socialFeeds
    case newsScroll
    case webBrowsing
    case rabbitHoles
    case consoleGaming
    case handheldGaming
    case music
    case podcasts
    case snacking
    case takeaway
    case sweets
    case coffee
    case alcohol
    case onlineShopping
    case windowShopping
    case napping
    case lyingIn
    case texting
    case videoCalls
    case hangingOut
}

enum CompanionID: String, CaseIterable, Codable, Hashable, Sendable {
    case phone
    case mug
    case wineGlass
    case smoking
    case snackBowl
    case controller
    case headphones

    var explicitOnly: Bool {
        self == .wineGlass || self == .smoking
    }
}

enum ScenePhase: String, CaseIterable, Codable, Hashable, Sendable {
    case presentLife
    case assembling
    case settled
    case exploringPossible
    case replacementComplete
    case history
    case graduation
}

enum MotionPreference: String, Codable, Hashable, Sendable {
    case standard
    case reduced
}

struct LifeSceneState: Equatable, Codable, Sendable {
    var indulgence: IndulgenceID
    var companion: CompanionID?
    var phase: ScenePhase
    var possibleProgress: Double
    var historyWeek: Int
    var motionPreference: MotionPreference

    init(
        indulgence: IndulgenceID = .television,
        companion: CompanionID? = nil,
        phase: ScenePhase = .presentLife,
        possibleProgress: Double = 0,
        historyWeek: Int = 1,
        motionPreference: MotionPreference = .standard
    ) {
        self.indulgence = indulgence
        self.companion = companion
        self.phase = phase
        self.possibleProgress = possibleProgress.clamped(to: 0...1)
        self.historyWeek = max(1, historyWeek)
        self.motionPreference = motionPreference
    }
}

extension LifeSceneState {
    static let watchingAlone = LifeSceneState(
        indulgence: .television,
        phase: .settled
    )

    static let watchingWithWine = LifeSceneState(
        indulgence: .television,
        companion: .wineGlass,
        phase: .settled
    )

    static let possibleLife = LifeSceneState(
        indulgence: .television,
        phase: .exploringPossible,
        possibleProgress: 1
    )

    static let replacementComplete = LifeSceneState(
        indulgence: .television,
        phase: .replacementComplete,
        possibleProgress: 1
    )

    static let historyWeekFour = LifeSceneState(
        indulgence: .television,
        phase: .history,
        possibleProgress: 0.72,
        historyWeek: 4
    )

    static let graduated = LifeSceneState(
        indulgence: .television,
        phase: .graduation,
        possibleProgress: 1
    )
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
