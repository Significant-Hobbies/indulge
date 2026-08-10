import RealityKit

@MainActor
struct SceneAssetRoleLoader {
    let root: Entity

    func entity(for role: SoftFormScene.Role) -> Entity? {
        root.findEntity(named: role.rawValue)
    }

    func containsEveryRequiredRole() -> Bool {
        SoftFormScene.Role.allCases.allSatisfy { entity(for: $0) != nil }
    }

    func replace(_ role: SoftFormScene.Role, with replacement: Entity) -> Bool {
        guard let current = entity(for: role), let parent = current.parent else {
            return false
        }

        replacement.name = role.rawValue
        replacement.transform = current.transform
        current.removeFromParent()
        parent.addChild(replacement)
        return true
    }
}
