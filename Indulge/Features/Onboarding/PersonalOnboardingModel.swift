import Foundation

enum PersonalOnboardingStep: Int, CaseIterable, Sendable {
    case name
    case gender
    case activities
    case primaryIndulgence
    case timeSpent
    case commonMoment
    case startingPattern
    case underlyingNeed
    case intentionality
    case lifeDirection
    case changePace
    case reflection

    static let mainJourney: [Self] = [
        .name,
        .gender,
        .activities,
        .primaryIndulgence,
        .timeSpent,
        .commonMoment,
        .startingPattern,
        .underlyingNeed,
        .intentionality,
        .lifeDirection,
        .changePace,
        .reflection
    ]

    var isOptional: Bool {
        switch self {
        case .activities, .primaryIndulgence, .underlyingNeed, .reflection: false
        default: true
        }
    }

    var showsSkipAction: Bool { false }

    var chapterTitle: String {
        switch self {
        case .name: "A quieter beginning"
        case .gender: "A little more about you"
        case .activities, .primaryIndulgence: "Where your time goes"
        case .timeSpent, .commonMoment, .startingPattern: "When it pulls you in"
        case .underlyingNeed, .intentionality: "What it gives you"
        case .lifeDirection, .changePace: "What you want more of"
        case .reflection: "Your first reflection"
        }
    }

    func title(for profile: OnboardingProfile) -> String {
        let name = profile.displayName == "you" ? "" : ", \(profile.displayName)"
        let activity = profile.primaryIndulgence?.title.lowercased() ?? "it"

        return switch self {
        case .name: "What should we call you?"
        case .gender: "How do you describe your gender?"
        case .activities: "What takes more of your time than you want?"
        case .primaryIndulgence: "Which one tends to keep you the longest\(name)?"
        case .timeSpent: "How much time does \(activity) usually take?"
        case .commonMoment: "When do you usually get pulled in?"
        case .startingPattern: "How does it usually begin?"
        case .underlyingNeed: profile.primaryIndulgence?.purposeQuestion ?? "What are you looking for in that moment?"
        case .intentionality: "How much of that time still feels chosen?"
        case .lifeDirection: "What would you love more room for?"
        case .changePace: "How much change feels kind?"
        case .reflection: profile.reflectionTitle
        }
    }

    func body(for profile: OnboardingProfile) -> String {
        switch self {
        case .name:
            ""
        case .gender:
            "Optional. We will not infer anything from this yet; it is simply part of the profile you are choosing to share."
        case .activities:
            ""
        case .primaryIndulgence:
            "No judgment. We are starting with the thing that most easily stretches beyond the moment."
        case .timeSpent:
            "Think of an ordinary day, not your best or worst one."
        case .commonMoment:
            "Choose every time that feels familiar."
        case .startingPattern:
            profile.commonMoments.count > 1
                ? "Those moments are familiar. Now let’s notice the tiny doorway into them."
                : "That moment is familiar. Now let’s notice the tiny doorway into it."
        case .underlyingNeed, .intentionality:
            ""
        case .lifeDirection:
            "You are not being asked to erase \(profile.primaryIndulgence?.title.lowercased() ?? "what you enjoy"). Choose up to three things you want beside it."
        case .changePace:
            "You want more \(profile.lifeDirectionSummary). You decide how softly we begin making that room."
        case .reflection:
            profile.reflectionBody
        }
    }

    var actionTitle: String {
        switch self {
        case .name: "Continue"
        case .gender: "Continue"
        case .activities: "Continue"
        case .primaryIndulgence: "That’s the one"
        case .timeSpent: "That sounds right"
        case .commonMoment: "Those are the times"
        case .startingPattern: "That’s familiar"
        case .underlyingNeed: "Continue"
        case .intentionality: "That’s honest"
        case .lifeDirection: "I want more of this"
        case .changePace: "Meet me there"
        case .reflection: "Start with this"
        }
    }
}

enum GenderIdentity: String, CaseIterable, Codable, Sendable {
    case woman
    case man
    case nonBinary
    case selfDescribe
    case preferNotToSay

    var title: String {
        switch self {
        case .woman: "Woman"
        case .man: "Man"
        case .nonBinary: "Non-binary"
        case .selfDescribe: "I describe it differently"
        case .preferNotToSay: "Prefer not to say"
        }
    }
}

enum IndulgenceChoice: String, CaseIterable, Codable, Hashable, Sendable {
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

    var title: String {
        switch self {
        case .television: "Watching TV"
        case .streaming: "Streaming a series"
        case .films: "Watching films"
        case .shortVideo: "Short videos"
        case .socialFeeds: "Social feeds"
        case .newsScroll: "Reading the news"
        case .webBrowsing: "Browsing the web"
        case .rabbitHoles: "Rabbit holes"
        case .consoleGaming: "Console gaming"
        case .handheldGaming: "Handheld gaming"
        case .music: "Listening to music"
        case .podcasts: "Listening to podcasts"
        case .snacking: "Snacking"
        case .takeaway: "Ordering takeaway"
        case .sweets: "Something sweet"
        case .coffee: "Having coffee"
        case .alcohol: "Having a drink"
        case .onlineShopping: "Shopping online"
        case .windowShopping: "Browsing shops"
        case .napping: "Taking a nap"
        case .lyingIn: "Lying in"
        case .texting: "Texting"
        case .videoCalls: "Video calling"
        case .hangingOut: "Hanging out"
        }
    }

    var icon: String {
        switch self {
        case .television: "tv.fill"
        case .streaming: "play.tv.fill"
        case .films: "film.fill"
        case .shortVideo: "play.rectangle.on.rectangle.fill"
        case .socialFeeds: "rectangle.stack.fill"
        case .newsScroll: "newspaper.fill"
        case .webBrowsing, .rabbitHoles: "safari.fill"
        case .consoleGaming, .handheldGaming: "gamecontroller.fill"
        case .music: "headphones"
        case .podcasts: "mic.fill"
        case .snacking: "takeoutbag.and.cup.and.straw.fill"
        case .takeaway: "bag.fill"
        case .sweets: "birthday.cake.fill"
        case .coffee: "cup.and.saucer.fill"
        case .alcohol: "wineglass.fill"
        case .onlineShopping, .windowShopping: "bag.fill"
        case .napping, .lyingIn: "bed.double.fill"
        case .texting: "message.fill"
        case .videoCalls: "video.fill"
        case .hangingOut: "person.2.fill"
        }
    }

    var selectorAssetName: String { rawValue }

    var purposeQuestion: String {
        switch self {
        case .television: "When you turn on the TV, what are you looking for?"
        case .streaming, .films: "When you put something on, what are you looking for?"
        case .shortVideo, .socialFeeds, .newsScroll: "When you start scrolling, what are you looking for?"
        case .webBrowsing, .rabbitHoles: "When you start browsing, what are you looking for?"
        case .consoleGaming, .handheldGaming: "When you start playing, what are you looking for?"
        case .music, .podcasts: "When you start listening, what are you looking for?"
        case .snacking, .takeaway, .sweets, .coffee, .alcohol: "When you reach for it, what are you looking for?"
        case .onlineShopping, .windowShopping: "When you start shopping, what are you looking for?"
        case .napping, .lyingIn: "When you stay in bed, what are you looking for?"
        case .texting, .videoCalls, .hangingOut: "When you reach for company, what are you looking for?"
        }
    }

    var isTelevisionFoundation: Bool {
        switch self {
        case .television, .streaming, .films: true
        default: false
        }
    }

    var isPhoneCompanion: Bool {
        switch self {
        case .shortVideo, .socialFeeds, .newsScroll, .webBrowsing, .rabbitHoles,
             .takeaway, .onlineShopping, .lyingIn, .texting, .videoCalls: true
        default: false
        }
    }

    var onboardingFamily: OnboardingActivityFamily {
        switch self {
        case .television, .streaming, .films:
            .watching
        case .shortVideo, .socialFeeds, .newsScroll, .texting:
            .scrolling
        case .webBrowsing, .rabbitHoles, .onlineShopping, .windowShopping:
            .browsing
        case .consoleGaming, .handheldGaming:
            .gaming
        case .music, .podcasts:
            .listening
        case .snacking, .takeaway, .sweets, .coffee, .alcohol:
            .taste
        case .napping, .lyingIn:
            .rest
        case .videoCalls, .hangingOut:
            .social
        }
    }
}

enum OnboardingActivityFamily: String, CaseIterable, Hashable, Sendable {
    case watching
    case scrolling
    case browsing
    case gaming
    case listening
    case taste
    case rest
    case social

    var title: String {
        switch self {
        case .watching: "Watch"
        case .scrolling: "Scroll"
        case .browsing: "Browse"
        case .gaming: "Game"
        case .listening: "Listen"
        case .taste: "Taste"
        case .rest: "Rest"
        case .social: "Social"
        }
    }

    var activities: [IndulgenceChoice] {
        IndulgenceChoice.allCases.filter { $0.onboardingFamily == self }
    }

    static var visibleActivities: [IndulgenceChoice] {
        allCases.flatMap(\.activities)
    }
}

enum DailyTime: String, CaseIterable, Codable, Sendable {
    case underThirty
    case aboutOneHour
    case twoHours
    case threePlus

    var title: String {
        switch self {
        case .underThirty: "Under 30 min"
        case .aboutOneHour: "About an hour"
        case .twoHours: "Around 2 hours"
        case .threePlus: "3 hours or more"
        }
    }

    var reflectionText: String {
        switch self {
        case .underThirty: "less than half an hour"
        case .aboutOneHour: "about an hour"
        case .twoHours: "around two hours"
        case .threePlus: "three hours or more"
        }
    }
}

enum CommonMoment: String, CaseIterable, Codable, Sendable {
    case morning
    case breaks
    case evening
    case lateNight

    var title: String {
        switch self {
        case .morning: "In the morning"
        case .breaks: "During breaks"
        case .evening: "In the evening"
        case .lateNight: "Late at night"
        }
    }

    var icon: String {
        switch self {
        case .morning: "sunrise.fill"
        case .breaks: "cup.and.heat.waves.fill"
        case .evening: "sunset.fill"
        case .lateNight: "moon.stars.fill"
        }
    }
}

enum StartingPattern: String, CaseIterable, Codable, Sendable {
    case planned
    case notification
    case boredom
    case difficultMoment
    case autopilot

    var title: String {
        switch self {
        case .planned: "I decide to"
        case .notification: "A notification pulls me in"
        case .boredom: "I feel bored"
        case .difficultMoment: "Something feels difficult"
        case .autopilot: "My hand just goes there"
        }
    }

    var reflectionPhrase: String {
        switch self {
        case .planned: "you decide to"
        case .notification: "a notification pulls you in"
        case .boredom: "you feel bored"
        case .difficultMoment: "something feels difficult"
        case .autopilot: "your hand just goes there"
        }
    }
}

enum IndulgenceNeed: String, CaseIterable, Codable, Sendable {
    case rest
    case comfort
    case escape
    case stimulation
    case connection

    var title: String {
        switch self {
        case .rest: "A chance to switch off"
        case .comfort: "Something comforting"
        case .escape: "A break from something"
        case .stimulation: "A little stimulation"
        case .connection: "A sense of connection"
        }
    }

    var icon: String {
        switch self {
        case .rest: "cloud.fill"
        case .comfort: "heart.fill"
        case .escape: "door.left.hand.open"
        case .stimulation: "sparkles"
        case .connection: "person.2.fill"
        }
    }
}

enum IntentionalityChoice: String, CaseIterable, Codable, Sendable {
    case mostlyChosen
    case mixed
    case mostlyAutomatic

    var title: String {
        switch self {
        case .mostlyChosen: "Mostly chosen"
        case .mixed: "A bit of both"
        case .mostlyAutomatic: "Mostly automatic"
        }
    }
}

enum LifeDirection: String, CaseIterable, Codable, Hashable, Sendable {
    case sleep
    case presence
    case relationships
    case creativity
    case movement
    case calm
    case focus
    case selfTrust

    var title: String {
        switch self {
        case .sleep: "Better sleep"
        case .presence: "More presence"
        case .relationships: "Closer relationships"
        case .creativity: "More creativity"
        case .movement: "More movement"
        case .calm: "A calmer mind"
        case .focus: "Deeper focus"
        case .selfTrust: "More self-trust"
        }
    }

    var icon: String {
        switch self {
        case .sleep: "moon.zzz.fill"
        case .presence: "eye.fill"
        case .relationships: "person.2.fill"
        case .creativity: "paintbrush.fill"
        case .movement: "figure.walk"
        case .calm: "water.waves"
        case .focus: "scope"
        case .selfTrust: "checkmark.seal.fill"
        }
    }

    var artworkAssetName: String { rawValue }
}

enum ChangePace: String, CaseIterable, Codable, Sendable {
    case noticeOnly
    case gentle
    case meaningful

    var title: String {
        switch self {
        case .noticeOnly: "Just help me notice"
        case .gentle: "A gentle shift"
        case .meaningful: "I’m ready for real change"
        }
    }

    var detail: String {
        switch self {
        case .noticeOnly: "No limits. Start with understanding."
        case .gentle: "A small pocket of time, without taking the pleasure away."
        case .meaningful: "A clearer boundary, still chosen by you."
        }
    }
}

struct OnboardingProfile: Codable, Equatable, Sendable {
    var preferredName = ""
    var gender: GenderIdentity?
    var customGender = ""
    var activities: Set<IndulgenceChoice> = []
    var primaryIndulgence: IndulgenceChoice?
    var dailyTime: DailyTime?
    var commonMoments: Set<CommonMoment> = []
    var startingPattern: StartingPattern?
    var need: IndulgenceNeed?
    var intentionality: IntentionalityChoice?
    var lifeDirections: Set<LifeDirection> = []
    var pace: ChangePace?

    var displayName: String {
        let trimmed = preferredName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "you" : trimmed
    }

    mutating func toggleActivity(_ activity: IndulgenceChoice, limit: Int = 5) {
        if activities.contains(activity) {
            activities.remove(activity)
            if primaryIndulgence == activity {
                primaryIndulgence = activities.sorted { $0.title < $1.title }.first
            }
        } else if activities.count < limit {
            activities.insert(activity)
            primaryIndulgence = activity
        }
    }

    func canAdvance(from step: PersonalOnboardingStep) -> Bool {
        return switch step {
        case .name, .reflection:
            true
        case .gender:
            gender.map { $0 != .selfDescribe || !customGender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? false
        case .activities:
            !activities.isEmpty
        case .primaryIndulgence:
            primaryIndulgence != nil
        case .timeSpent:
            dailyTime != nil
        case .commonMoment:
            !commonMoments.isEmpty
        case .startingPattern:
            startingPattern != nil
        case .underlyingNeed:
            need != nil
        case .intentionality:
            intentionality != nil
        case .lifeDirection:
            !lifeDirections.isEmpty
        case .changePace:
            pace != nil
        }
    }

    mutating func clearAnswer(for step: PersonalOnboardingStep) {
        switch step {
        case .name: preferredName = ""
        case .gender:
            gender = .preferNotToSay
            customGender = ""
        case .timeSpent: dailyTime = nil
        case .commonMoment: commonMoments.removeAll()
        case .startingPattern: startingPattern = nil
        case .underlyingNeed: need = nil
        case .intentionality: intentionality = nil
        case .lifeDirection: lifeDirections.removeAll()
        case .changePace: pace = nil
        case .activities, .primaryIndulgence, .reflection: break
        }
    }

    var reflectionTitle: String {
        displayName == "you" ? "Here’s the pattern you shared." : "\(displayName), here’s your pattern."
    }

    var reflectionBody: String {
        let activity = primaryIndulgence?.title.lowercased() ?? "this pleasure"
        var sentences = ["You enjoy \(activity)\(dailyTime.map { ", and it can hold \($0.reflectionText) of an ordinary day" } ?? "")."]

        if !commonMoments.isEmpty {
            let opening = startingPattern.map { ", often beginning when \($0.reflectionPhrase)" } ?? ""
            sentences.append("It tends to pull you in \(commonMomentSummary)\(opening).")
        } else if let startingPattern {
            sentences.append("It often begins when \(startingPattern.reflectionPhrase).")
        }

        if let need {
            sentences.append("In that moment, it gives you \(need.title.lowercased()).")
        }

        if let intentionality {
            let sentence = switch intentionality {
            case .mostlyChosen: "The time still feels mostly chosen."
            case .mixed: "Some of that time feels chosen, and some begins to run on its own."
            case .mostlyAutomatic: "Lately, most of that time feels automatic rather than chosen."
            }
            sentences.append(sentence)
        }

        if !lifeDirections.isEmpty {
            sentences.append("You want more room for \(lifeDirectionSummary), without turning pleasure into punishment.")
        }

        if let pace {
            sentences.append("You asked to begin with \(pace.title.lowercased()).")
        }

        return sentences.joined(separator: "\n\n")
    }

    var lifeDirectionSummary: String {
        let values = lifeDirections.sorted { $0.rawValue < $1.rawValue }.map { $0.title.lowercased() }
        return switch values.count {
        case 0: "what matters to you"
        case 1: values[0]
        case 2: "\(values[0]) and \(values[1])"
        default: "\(values.dropLast().joined(separator: ", ")), and \(values.last!)"
        }
    }

    var commonMomentSummary: String {
        let values = CommonMoment.allCases
            .filter(commonMoments.contains)
            .map { $0.title.lowercased() }

        return switch values.count {
        case 0: "at familiar moments"
        case 1: values[0]
        case 2: "\(values[0]) and \(values[1])"
        default: "\(values.dropLast().joined(separator: ", ")), and \(values.last!)"
        }
    }

    var visualState: OnboardingVisualState {
        let hasTelevisionFoundation = activities.contains(where: \.isTelevisionFoundation)
        let televisionState = OnboardingVisualState.watchingTelevision(
            phone: activities.contains { $0.onboardingFamily == .scrolling },
            drink: activities.contains(.alcohol)
        )

        switch primaryIndulgence?.onboardingFamily {
        case .watching:
            return televisionState
        case .scrolling:
            return hasTelevisionFoundation ? televisionState : .scrolling
        case .browsing:
            return .browsing
        case .gaming:
            return .gaming
        case .listening:
            return .listening
        case .taste:
            if primaryIndulgence == .alcohol && hasTelevisionFoundation {
                return televisionState
            }
            return .taste
        case .rest:
            return .rest
        case .social:
            return .social
        case nil:
            break
        }

        if hasTelevisionFoundation {
            return televisionState
        }
        return .standing
    }

    var characterPresentation: CharacterPresentation {
        gender == .man ? .masculine : .feminine
    }
}

enum OnboardingVisualState: Equatable, Hashable, Sendable {
    case standing
    case watchingTelevision(phone: Bool, drink: Bool)
    case scrolling
    case browsing
    case gaming
    case listening
    case taste
    case rest
    case social

    func sceneAssetName(for presentation: CharacterPresentation) -> String {
        let identity = presentation == .feminine ? "Feminine" : "Masculine"
        return switch self {
        case .standing:
            "SceneStanding\(identity)"
        case let .watchingTelevision(phone, drink):
            if phone && drink { "SceneStack\(identity)" }
            else if phone { "SceneTelevisionPhone\(identity)" }
            else if drink { "SceneTelevisionDrink\(identity)" }
            else { "SceneTelevision\(identity)" }
        case .scrolling:
            "SceneScrolling\(identity)"
        case .browsing:
            "SceneBrowsing\(identity)"
        case .gaming:
            "SceneGaming\(identity)"
        case .listening:
            "SceneListening\(identity)"
        case .taste:
            "SceneTaste\(identity)"
        case .rest:
            "SceneRest\(identity)"
        case .social:
            "SceneSocial\(identity)"
        }
    }
}

enum OnboardingSceneTransition: Equatable, Sendable {
    case none
    case assembleWatching
    case addCompanion
    case removeCompanion
    case replaceScene

    static func resolve(from oldState: OnboardingVisualState, to newState: OnboardingVisualState) -> Self {
        guard oldState != newState else { return .none }

        switch (oldState, newState) {
        case (_, .watchingTelevision) where !oldState.isWatchingTelevision:
            return .assembleWatching
        case let (.watchingTelevision(oldPhone, oldDrink), .watchingTelevision(newPhone, newDrink)):
            let oldCount = [oldPhone, oldDrink].filter { $0 }.count
            let newCount = [newPhone, newDrink].filter { $0 }.count
            return newCount > oldCount ? .addCompanion : .removeCompanion
        default:
            return .replaceScene
        }
    }
}

private extension OnboardingVisualState {
    var isWatchingTelevision: Bool {
        if case .watchingTelevision = self { return true }
        return false
    }
}

enum CharacterPresentation: String, Equatable, Hashable, Sendable {
    case feminine
    case masculine
}

enum PersonalOnboardingPreset: String, Sendable, Equatable {
    case welcome
    case name
    case keyboard
    case gender
    case activities
    case activitiesMale
    case scrolling
    case browsing
    case gaming
    case listening
    case taste
    case resting
    case social
    case time
    case moments
    case purpose
    case life
    case reflection
    case reduced
    case sceneDemo

    static var launchArguments: PersonalOnboardingPreset {
        let arguments = ProcessInfo.processInfo.arguments
        for preset in Self.allCasesForLaunch where arguments.contains("--personal-\(preset.rawValue)") {
            return preset
        }
        return .welcome
    }

    private static let allCasesForLaunch: [PersonalOnboardingPreset] = [
        .name, .keyboard, .gender, .activities, .activitiesMale, .scrolling, .browsing, .gaming, .listening, .taste, .resting, .social, .time, .moments, .purpose, .life, .reflection, .reduced, .sceneDemo
    ]

    var step: PersonalOnboardingStep {
        switch self {
        case .welcome: .name
        case .name, .keyboard: .name
        case .gender: .gender
        case .activities, .activitiesMale, .scrolling, .browsing, .gaming, .listening, .taste, .resting, .social, .sceneDemo: .activities
        case .time: .timeSpent
        case .moments: .commonMoment
        case .purpose: .underlyingNeed
        case .life: .lifeDirection
        case .reflection: .reflection
        case .reduced: .activities
        }
    }

    var focusesTextEntry: Bool { self == .keyboard }

    var profile: OnboardingProfile {
        guard self != .welcome && self != .name && self != .keyboard && self != .sceneDemo else {
            return self == .sceneDemo ? OnboardingProfile(gender: .woman) : OnboardingProfile()
        }
        var profile = OnboardingProfile(
            preferredName: "Maya",
            gender: .woman,
            activities: [.television, .shortVideo, .alcohol],
            primaryIndulgence: .television,
            dailyTime: .twoHours,
            commonMoments: [.evening],
            startingPattern: .autopilot,
            need: .comfort,
            intentionality: .mixed,
            lifeDirections: [.presence, .creativity],
            pace: .gentle
        )
        if self == .gender {
            profile.gender = nil
            profile.customGender = ""
        }
        if self == .activitiesMale { profile.gender = .man }
        if self == .scrolling {
            profile.activities = [.shortVideo]
            profile.primaryIndulgence = .shortVideo
        }
        if self == .browsing {
            profile.activities = [.webBrowsing]
            profile.primaryIndulgence = .webBrowsing
        }
        if self == .gaming {
            profile.activities = [.consoleGaming]
            profile.primaryIndulgence = .consoleGaming
        }
        if self == .listening {
            profile.activities = [.music]
            profile.primaryIndulgence = .music
        }
        if self == .taste {
            profile.activities = [.snacking]
            profile.primaryIndulgence = .snacking
        }
        if self == .resting {
            profile.activities = [.napping]
            profile.primaryIndulgence = .napping
        }
        if self == .social {
            profile.activities = [.videoCalls]
            profile.primaryIndulgence = .videoCalls
        }
        if self == .purpose {
            profile.activities = [.shortVideo]
            profile.primaryIndulgence = .shortVideo
            profile.need = nil
        }
        if self == .moments {
            profile.commonMoments = [.breaks, .evening, .lateNight]
        }
        if self == .reduced { profile.primaryIndulgence = nil }
        return profile
    }

    var forcesReduceMotion: Bool { self == .reduced }

    var automaticallyDemonstratesScene: Bool { self == .sceneDemo }
}
