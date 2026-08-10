import Foundation

enum CharacterPose: String, CaseIterable, Codable, Hashable, Sendable {
    case standing
    case sofaSeated
    case chairSeated
    case reclined
    case crossLegged
}

enum EnvironmentCluster: String, CaseIterable, Codable, Hashable, Sendable {
    case livingRoom
    case desk
    case gaming
    case listening
    case cafe
    case bedroom
    case social
}

enum PropSocket: String, CaseIterable, Codable, Hashable, Sendable {
    case leftHand
    case rightHand
    case lap
    case sideTable
}

enum CameraTarget: String, CaseIterable, Codable, Hashable, Sendable {
    case fullBody
    case seatedWide
    case desk
    case intimate
}

enum AmbientLoop: String, CaseIterable, Codable, Hashable, Sendable {
    case breathe
    case screenGlow
    case footTap
    case headNod
    case steam
    case conversation
}

enum ArrivalPhase: String, CaseIterable, Codable, Hashable, Sendable {
    case stage
    case environment
    case characterResponse
    case primaryObject
    case companion
    case settle
}

struct CompanionRecipe: Equatable, Hashable, Codable, Sendable {
    let id: CompanionID
    let preferredSocket: PropSocket
    let allowedSockets: Set<PropSocket>

    var explicitOnly: Bool { id.explicitOnly }
}

struct IndulgenceRecipe: Equatable, Hashable, Codable, Sendable {
    let id: IndulgenceID
    let title: String
    let familyLabel: String
    let basePose: CharacterPose
    let environment: EnvironmentCluster
    let cameraTarget: CameraTarget
    let defaultCompanions: [CompanionID]
    let ambientLoops: Set<AmbientLoop>
    let arrivalPhases: [ArrivalPhase]
}

enum CompanionResolution: Equatable, Sendable {
    case attached(CompanionID, PropSocket)
    case omitted(CompanionID)
}

struct ResolvedSceneRecipe: Equatable, Sendable {
    let recipe: IndulgenceRecipe
    let companion: CompanionResolution?
}

struct ResolvedSceneComposition: Equatable, Sendable {
    let recipe: IndulgenceRecipe
    let companions: [CompanionResolution]
}

enum SceneCompatibility {
    private static let companionPlacementOrder: [CompanionID] = [
        .smoking,
        .phone,
        .snackBowl,
        .controller,
        .wineGlass,
        .mug,
        .headphones
    ]

    static let socketsByPose: [CharacterPose: Set<PropSocket>] = [
        .standing: [.leftHand, .rightHand],
        .sofaSeated: [.leftHand, .rightHand, .lap, .sideTable],
        .chairSeated: [.leftHand, .rightHand, .lap, .sideTable],
        .reclined: [.rightHand, .sideTable],
        .crossLegged: [.leftHand, .rightHand, .lap]
    ]

    static func resolve(
        recipe: IndulgenceRecipe,
        requested companion: CompanionID?,
        companionRecipes: [CompanionID: CompanionRecipe]
    ) -> ResolvedSceneRecipe {
        guard let companion,
              let companionRecipe = companionRecipes[companion]
        else {
            return ResolvedSceneRecipe(recipe: recipe, companion: nil)
        }

        let supported = socketsByPose[recipe.basePose, default: []]
        if supported.contains(companionRecipe.preferredSocket) {
            return ResolvedSceneRecipe(
                recipe: recipe,
                companion: .attached(companion, companionRecipe.preferredSocket)
            )
        }

        let fallback = companionRecipe.allowedSockets
            .intersection(supported)
            .sorted { $0.rawValue < $1.rawValue }
            .first

        if let fallback {
            return ResolvedSceneRecipe(
                recipe: recipe,
                companion: .attached(companion, fallback)
            )
        }

        return ResolvedSceneRecipe(recipe: recipe, companion: .omitted(companion))
    }

    static func resolve(
        recipe: IndulgenceRecipe,
        requested companions: Set<CompanionID>,
        companionRecipes: [CompanionID: CompanionRecipe]
    ) -> ResolvedSceneComposition {
        let supported = socketsByPose[recipe.basePose, default: []]
        var occupied = Set<PropSocket>()

        let resolutions = companionPlacementOrder
            .filter(companions.contains)
            .map { companion -> CompanionResolution in
                guard let companionRecipe = companionRecipes[companion] else {
                    return .omitted(companion)
                }

                let candidates = [companionRecipe.preferredSocket] + companionRecipe.allowedSockets
                    .intersection(supported)
                    .filter { $0 != companionRecipe.preferredSocket }
                    .sorted { $0.rawValue < $1.rawValue }

                guard let socket = candidates.first(where: { supported.contains($0) && !occupied.contains($0) }) else {
                    return .omitted(companion)
                }

                occupied.insert(socket)
                return .attached(companion, socket)
            }

        return ResolvedSceneComposition(recipe: recipe, companions: resolutions)
    }
}
