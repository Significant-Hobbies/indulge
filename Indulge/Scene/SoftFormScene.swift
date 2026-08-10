import RealityKit
import SwiftUI
import UIKit

enum SceneAssemblyStage: Int, CaseIterable, Sendable {
    case standing
    case stageArrived
    case sofaArrived
    case seated
    case televisionArrived
    case settled
}

@MainActor
enum SoftFormScene {
    static let rootName = "indulge-scene-root"

    enum Role: String, CaseIterable {
        case stage
        case sofa
        case television
        case lamp
        case avatar
        case torso
        case head
        case leftArm
        case rightArm
        case leftHand
        case rightHand
        case leftLeg
        case rightLeg
        case leftHandSocket
        case rightHandSocket
        case mug
        case wineGlass
        case smoking
        case phone
        case possibleWorld
        case camera
    }

    static func makeRoot() -> Entity {
        let root = Entity()
        root.name = rootName

        root.addChild(makeStage())
        root.addChild(makeSofa())
        root.addChild(makeTelevision())
        root.addChild(makeLamp())
        root.addChild(makeAvatar())
        root.addChild(makePossibleWorld())
        root.addChild(makeCamera())
        root.addChild(makeLight())

        apply(
            root: root,
            assembly: .standing,
            companion: nil,
            possibleProgress: 0,
            reduceMotion: false,
            animated: false
        )
        return root
    }

    static func apply(
        root: Entity,
        assembly: SceneAssemblyStage,
        companion: CompanionID?,
        possibleProgress: Double,
        reduceMotion: Bool,
        animated: Bool,
        ambientPulse: Float = 0
    ) {
        let progress = Float(min(max(possibleProgress, 0), 1))
        let duration: TimeInterval = reduceMotion || !animated ? 0 : 0.55

        set(
            role: .stage,
            in: root,
            transform: transform(
                position: [0, assembly.rawValue >= SceneAssemblyStage.stageArrived.rawValue ? -0.82 : -1.25, 0],
                scale: assembly == .standing ? 0.82 : 1
            ),
            duration: duration
        )

        let sofaVisible = assembly.rawValue >= SceneAssemblyStage.sofaArrived.rawValue
        let sofaPosition = simd_mix(
            SIMD3<Float>(-0.65, sofaVisible ? -0.20 : -1.22, 0.16),
            SIMD3<Float>(-1.08, -0.43, -0.52),
            SIMD3<Float>(repeating: progress)
        )
        set(
            role: .sofa,
            in: root,
            transform: transform(
                position: sofaPosition,
                rotation: simd_quatf(angle: -0.10, axis: [0, 1, 0]),
                scale: sofaVisible ? max(0.04, 1 - progress * 0.58) : 0.04
            ),
            duration: duration
        )

        let televisionVisible = assembly.rawValue >= SceneAssemblyStage.televisionArrived.rawValue
        let televisionPosition = simd_mix(
            SIMD3<Float>(1.18, televisionVisible ? -0.18 : 0.55, -0.22),
            SIMD3<Float>(1.42, -0.38, -0.58),
            SIMD3<Float>(repeating: progress)
        )
        set(
            role: .television,
            in: root,
            transform: transform(
                position: televisionPosition,
                rotation: simd_quatf(angle: -0.34, axis: [0, 1, 0]),
                scale: televisionVisible ? max(0.04, 1 - progress * 0.72) : 0.04
            ),
            duration: duration
        )

        let lampVisible = assembly == .settled
        set(
            role: .lamp,
            in: root,
            transform: transform(
                position: [-1.48, lampVisible ? -0.20 : 0.45, 0.12],
                scale: lampVisible ? max(0.04, 1 - progress * 0.74) : 0.04
            ),
            duration: duration
        )

        applyAvatarPose(
            root: root,
            seated: assembly.rawValue >= SceneAssemblyStage.seated.rawValue,
            possibleProgress: progress,
            ambientPulse: ambientPulse,
            duration: duration
        )
        applyCompanion(root: root, companion: companion, seated: sofaVisible, duration: duration)

        if let possible = root.findEntity(named: Role.possibleWorld.rawValue) {
            possible.transform = transform(
                position: [0.38, -0.02 + progress * 0.08, -0.08],
                scale: max(0.001, progress)
            )
            possible.components.set(OpacityComponent(opacity: progress))
        }

        if let camera = root.findEntity(named: Role.camera.rawValue) {
            let from = SIMD3<Float>(3.7 - progress * 0.45, 2.45 + progress * 0.16, 5.25 - progress * 0.32)
            camera.look(at: [0, 0.18 + progress * 0.12, 0], from: from, relativeTo: nil)
        }
    }

    nonisolated static func semanticSummary(
        assembly: SceneAssemblyStage,
        companion: CompanionID?,
        possibleProgress: Double
    ) -> String {
        if possibleProgress > 0.75 {
            return "Your character stands in a brighter life with books, movement, creativity, plants, and connection."
        }

        let action = assembly.rawValue >= SceneAssemblyStage.seated.rawValue
            ? "Your character is seated on a soft green sofa, watching television"
            : "Your character is standing in an empty teal room"

        switch companion {
        case .wineGlass:
            return action + " with a wine glass in hand."
        case .smoking:
            return action + " with the smoking choice you explicitly added."
        case .mug:
            return action + " with a mug in hand."
        case .phone:
            return action + " with a phone in hand."
        default:
            return action + "."
        }
    }

    private static func applyAvatarPose(
        root: Entity,
        seated: Bool,
        possibleProgress: Float,
        ambientPulse: Float,
        duration: TimeInterval
    ) {
        guard let avatar = root.findEntity(named: Role.avatar.rawValue) else { return }
        let basePosition: SIMD3<Float> = seated ? [-0.53, -0.04, 0.43] : [-0.30, -0.48, 0.08]
        let possiblePosition = SIMD3<Float>(0.05, -0.48, -0.05)
        var position = simd_mix(basePosition, possiblePosition, SIMD3<Float>(repeating: possibleProgress))
        position.y += ambientPulse * 0.012 * (1 - possibleProgress)
        move(avatar, to: transform(position: position), duration: duration)

        let legAngle: Float = seated ? -Float.goldenHalfPi * (1 - possibleProgress) : -0.06
        let armAngle: Float = seated ? -0.42 * (1 - possibleProgress) : -0.14
        rotate(role: .leftLeg, in: avatar, angle: legAngle, axis: [1, 0, 0], duration: duration)
        rotate(role: .rightLeg, in: avatar, angle: legAngle + 0.08, axis: [1, 0, 0], duration: duration)
        rotate(role: .leftArm, in: avatar, angle: armAngle, axis: [1, 0, 0], duration: duration)
        rotate(role: .rightArm, in: avatar, angle: armAngle - 0.12, axis: [1, 0, 0], duration: duration)

        if possibleProgress > 0 {
            rotate(role: .leftArm, in: avatar, angle: -0.65 * possibleProgress, axis: [0, 0, 1], duration: 0)
            rotate(role: .rightArm, in: avatar, angle: 0.65 * possibleProgress, axis: [0, 0, 1], duration: 0)
        }
    }

    private static func applyCompanion(
        root: Entity,
        companion: CompanionID?,
        seated: Bool,
        duration: TimeInterval
    ) {
        let visibleRole: Role? = switch companion {
        case .wineGlass: .wineGlass
        case .smoking: .smoking
        case .mug: .mug
        case .phone: .phone
        default: nil
        }

        for role in [Role.mug, .wineGlass, .smoking, .phone] {
            guard let entity = root.findEntity(named: role.rawValue) else { continue }
            let visible = role == visibleRole
            let position: SIMD3<Float> = switch role {
            case .smoking: [-0.72, seated ? 0.68 : 0.94, 0.42]
            default: [-0.22, seated ? 0.60 : 0.89, 0.30]
            }
            move(
                entity,
                to: transform(position: position, scale: visible ? 1 : 0.001),
                duration: duration
            )
            entity.components.set(OpacityComponent(opacity: visible ? 1 : 0))
        }
    }

    private static func makeStage() -> Entity {
        let stage = Entity()
        stage.name = Role.stage.rawValue
        stage.addChild(box(size: [3.75, 0.18, 2.42], radius: 0.09, material: Materials.stage, position: .zero))
        stage.addChild(oval(size: [0.55, 0.018, 0.30], material: Materials.shadow, position: [-0.30, 0.11, 0.02]))
        return stage
    }

    private static func makeSofa() -> Entity {
        let sofa = Entity()
        sofa.name = Role.sofa.rawValue
        sofa.addChild(box(size: [1.82, 0.34, 0.70], radius: 0.16, material: Materials.sofa, position: [0, 0.12, 0]))
        sofa.addChild(box(size: [1.75, 0.62, 0.25], radius: 0.12, material: Materials.sofaBack, position: [0, 0.48, 0.24]))
        sofa.addChild(box(size: [0.28, 0.55, 0.72], radius: 0.14, material: Materials.sofaBack, position: [-0.92, 0.27, 0]))
        sofa.addChild(box(size: [0.28, 0.55, 0.72], radius: 0.14, material: Materials.sofaBack, position: [0.92, 0.27, 0]))
        sofa.addChild(box(size: [0.76, 0.18, 0.58], radius: 0.09, material: Materials.cushion, position: [-0.43, 0.35, -0.03]))
        sofa.addChild(box(size: [0.76, 0.18, 0.58], radius: 0.09, material: Materials.cushion, position: [0.43, 0.35, -0.03]))
        sofa.addChild(box(size: [0.10, 0.28, 0.10], radius: 0.04, material: Materials.wood, position: [-0.70, -0.16, 0]))
        sofa.addChild(box(size: [0.10, 0.28, 0.10], radius: 0.04, material: Materials.wood, position: [0.70, -0.16, 0]))
        return sofa
    }

    private static func makeTelevision() -> Entity {
        let television = Entity()
        television.name = Role.television.rawValue
        television.addChild(box(size: [1.12, 0.70, 0.10], radius: 0.07, material: Materials.tvFrame, position: [0, 0.66, 0]))
        television.addChild(box(size: [0.96, 0.55, 0.02], radius: 0.04, material: Materials.screen, position: [0, 0.66, 0.061]))
        television.addChild(box(size: [0.10, 0.52, 0.10], radius: 0.04, material: Materials.wood, position: [0, 0.22, 0]))
        television.addChild(box(size: [0.70, 0.10, 0.38], radius: 0.04, material: Materials.wood, position: [0, -0.02, 0]))
        return television
    }

    private static func makeLamp() -> Entity {
        let lamp = Entity()
        lamp.name = Role.lamp.rawValue
        lamp.addChild(box(size: [0.08, 1.16, 0.08], radius: 0.03, material: Materials.brass, position: [0, 0.34, 0]))
        lamp.addChild(box(size: [0.42, 0.34, 0.42], radius: 0.11, material: Materials.lampShade, position: [0, 0.96, 0]))
        lamp.addChild(box(size: [0.42, 0.07, 0.42], radius: 0.03, material: Materials.brass, position: [0, -0.22, 0]))
        return lamp
    }

    private static func makeAvatar() -> Entity {
        let avatar = Entity()
        avatar.name = Role.avatar.rawValue

        let torso = oval(size: [0.48, 0.62, 0.30], material: Materials.shirt, position: [0, 0.67, 0])
        torso.name = Role.torso.rawValue
        avatar.addChild(torso)

        let head = oval(size: [0.34, 0.39, 0.34], material: Materials.skin, position: [0, 1.22, 0])
        head.name = Role.head.rawValue
        avatar.addChild(head)
        avatar.addChild(oval(size: [0.34, 0.16, 0.32], material: Materials.hair, position: [0, 1.39, -0.01]))
        avatar.addChild(oval(size: [0.055, 0.070, 0.025], material: Materials.dark, position: [-0.07, 1.25, 0.17]))
        avatar.addChild(oval(size: [0.055, 0.070, 0.025], material: Materials.dark, position: [0.07, 1.25, 0.17]))
        avatar.addChild(oval(size: [0.075, 0.035, 0.025], material: Materials.coral, position: [0, 1.14, 0.17]))

        avatar.addChild(oval(size: [0.24, 0.25, 0.24], material: Materials.shirt, position: [-0.27, 0.85, 0]))
        avatar.addChild(oval(size: [0.24, 0.25, 0.24], material: Materials.shirt, position: [0.27, 0.85, 0]))

        avatar.addChild(limb(name: Role.leftArm.rawValue, size: [0.15, 0.52, 0.15], position: [-0.33, 0.72, 0.02], material: Materials.skin))
        avatar.addChild(limb(name: Role.rightArm.rawValue, size: [0.15, 0.52, 0.15], position: [0.33, 0.72, 0.02], material: Materials.skin))
        avatar.addChild(limb(name: Role.leftLeg.rawValue, size: [0.19, 0.66, 0.19], position: [-0.15, 0.14, 0], material: Materials.trousers))
        avatar.addChild(limb(name: Role.rightLeg.rawValue, size: [0.19, 0.66, 0.19], position: [0.15, 0.14, 0], material: Materials.trousers))

        avatar.addChild(oval(size: [0.26, 0.12, 0.40], material: Materials.shoe, position: [-0.15, -0.23, 0.10]))
        avatar.addChild(oval(size: [0.26, 0.12, 0.40], material: Materials.shoe, position: [0.15, -0.23, 0.10]))

        let leftHand = oval(size: [0.15, 0.15, 0.15], material: Materials.skin, position: [-0.33, 0.40, 0.02])
        leftHand.name = Role.leftHand.rawValue
        avatar.addChild(leftHand)
        let rightHand = oval(size: [0.15, 0.15, 0.15], material: Materials.skin, position: [0.33, 0.40, 0.02])
        rightHand.name = Role.rightHand.rawValue
        avatar.addChild(rightHand)

        let leftSocket = Entity()
        leftSocket.name = Role.leftHandSocket.rawValue
        leftSocket.position = [-0.33, 0.40, 0.12]
        avatar.addChild(leftSocket)
        let rightSocket = Entity()
        rightSocket.name = Role.rightHandSocket.rawValue
        rightSocket.position = [0.33, 0.40, 0.12]
        avatar.addChild(rightSocket)

        let mug = makeMug()
        mug.name = Role.mug.rawValue
        avatar.addChild(mug)
        let wine = makeWineGlass()
        wine.name = Role.wineGlass.rawValue
        avatar.addChild(wine)
        let smoking = box(size: [0.025, 0.025, 0.23], radius: 0.01, material: Materials.paper, position: .zero)
        smoking.name = Role.smoking.rawValue
        avatar.addChild(smoking)
        let phone = box(size: [0.15, 0.28, 0.025], radius: 0.03, material: Materials.phone, position: .zero)
        phone.name = Role.phone.rawValue
        avatar.addChild(phone)

        return avatar
    }

    private static func makePossibleWorld() -> Entity {
        let world = Entity()
        world.name = Role.possibleWorld.rawValue

        let arch = Entity()
        arch.addChild(box(size: [0.16, 1.45, 0.16], radius: 0.07, material: Materials.sun, position: [-1.25, 0.08, -0.35]))
        arch.addChild(box(size: [0.16, 1.45, 0.16], radius: 0.07, material: Materials.sun, position: [1.25, 0.08, -0.35]))
        arch.addChild(box(size: [2.66, 0.16, 0.16], radius: 0.07, material: Materials.sun, position: [0, 0.79, -0.35]))
        world.addChild(arch)

        let bookStack = Entity()
        bookStack.addChild(box(size: [0.48, 0.10, 0.34], radius: 0.03, material: Materials.coral, position: [-1.02, -0.48, 0.15]))
        bookStack.addChild(box(size: [0.42, 0.10, 0.32], radius: 0.03, material: Materials.sun, position: [-1.02, -0.37, 0.15]))
        bookStack.addChild(box(size: [0.46, 0.10, 0.34], radius: 0.03, material: Materials.sky, position: [-1.02, -0.26, 0.15]))
        world.addChild(bookStack)

        world.addChild(box(size: [0.78, 0.035, 1.20], radius: 0.02, material: Materials.yoga, position: [0.98, -0.66, 0.12]))
        world.addChild(box(size: [0.08, 0.95, 0.08], radius: 0.03, material: Materials.wood, position: [0.78, -0.12, -0.12]))
        world.addChild(box(size: [0.76, 0.62, 0.06], radius: 0.03, material: Materials.canvas, position: [0.78, 0.22, -0.10]))

        let plant = Entity()
        plant.addChild(box(size: [0.30, 0.28, 0.30], radius: 0.08, material: Materials.coral, position: [-1.18, -0.52, -0.42]))
        plant.addChild(oval(size: [0.22, 0.55, 0.12], material: Materials.plant, position: [-1.30, -0.12, -0.42]))
        plant.addChild(oval(size: [0.22, 0.50, 0.12], material: Materials.plant, position: [-1.05, -0.15, -0.42]))
        world.addChild(plant)

        let connection = Entity()
        connection.addChild(oval(size: [0.20, 0.25, 0.20], material: Materials.skin, position: [-1.30, 0.04, -0.48]))
        connection.addChild(oval(size: [0.27, 0.39, 0.22], material: Materials.sky, position: [-1.30, -0.25, -0.48]))
        connection.addChild(oval(size: [0.20, 0.25, 0.20], material: Materials.skin, position: [-0.98, 0.04, -0.48]))
        connection.addChild(oval(size: [0.27, 0.39, 0.22], material: Materials.coral, position: [-0.98, -0.25, -0.48]))
        world.addChild(connection)

        return world
    }

    private static func makeCamera() -> Entity {
        let camera = PerspectiveCamera()
        camera.name = Role.camera.rawValue
        camera.camera.fieldOfViewInDegrees = 34
        camera.look(at: [0, 0.22, 0], from: [3.7, 2.45, 5.25], relativeTo: nil)
        return camera
    }

    private static func makeLight() -> Entity {
        let light = DirectionalLight()
        light.name = "key-light"
        light.light.color = .init(red: 1.0, green: 0.92, blue: 0.80, alpha: 1)
        light.light.intensity = 3_300
        light.look(at: [0, 0, 0], from: [-2.5, 4.8, 4.0], relativeTo: nil)
        return light
    }

    private static func makeMug() -> Entity {
        let mug = Entity()
        mug.addChild(box(size: [0.18, 0.22, 0.18], radius: 0.05, material: Materials.mug, position: .zero))
        mug.addChild(box(size: [0.07, 0.12, 0.05], radius: 0.02, material: Materials.mug, position: [0.12, 0, 0]))
        return mug
    }

    private static func makeWineGlass() -> Entity {
        let glass = Entity()
        glass.addChild(oval(size: [0.16, 0.18, 0.16], material: Materials.wine, position: [0, 0.11, 0]))
        glass.addChild(box(size: [0.025, 0.18, 0.025], radius: 0.01, material: Materials.glass, position: [0, -0.06, 0]))
        glass.addChild(oval(size: [0.14, 0.025, 0.14], material: Materials.glass, position: [0, -0.16, 0]))
        return glass
    }

    private static func limb(name: String, size: SIMD3<Float>, position: SIMD3<Float>, material: SimpleMaterial) -> Entity {
        let pivot = Entity()
        pivot.name = name
        pivot.position = position
        pivot.addChild(oval(size: size, material: material, position: [0, -size.y * 0.33, 0]))
        return pivot
    }

    private static func box(
        size: SIMD3<Float>,
        radius: Float,
        material: SimpleMaterial,
        position: SIMD3<Float>
    ) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateBox(size: size, cornerRadius: radius),
            materials: [material]
        )
        entity.position = position
        return entity
    }

    private static func oval(
        size: SIMD3<Float>,
        material: SimpleMaterial,
        position: SIMD3<Float>
    ) -> ModelEntity {
        let entity = ModelEntity(mesh: .generateSphere(radius: 0.5), materials: [material])
        entity.position = position
        entity.scale = size
        return entity
    }

    private static func rotate(
        role: Role,
        in root: Entity,
        angle: Float,
        axis: SIMD3<Float>,
        duration: TimeInterval
    ) {
        guard let entity = root.findEntity(named: role.rawValue) else { return }
        var target = entity.transform
        target.rotation = simd_quatf(angle: angle, axis: axis)
        move(entity, to: target, duration: duration)
    }

    private static func set(role: Role, in root: Entity, transform: Transform, duration: TimeInterval) {
        guard let entity = root.findEntity(named: role.rawValue) else { return }
        move(entity, to: transform, duration: duration)
    }

    private static func move(_ entity: Entity, to transform: Transform, duration: TimeInterval) {
        if duration == 0 {
            entity.transform = transform
        } else {
            entity.move(to: transform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
        }
    }

    private static func transform(
        position: SIMD3<Float>,
        rotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0]),
        scale: Float = 1
    ) -> Transform {
        Transform(scale: SIMD3<Float>(repeating: scale), rotation: rotation, translation: position)
    }
}

private extension Float {
    static let goldenHalfPi: Float = 1.25
}

@MainActor
private enum Materials {
    static let stage = matte(0xE8CDAE)
    static let shadow = matte(0x173B3A, alpha: 0.32)
    static let sofa = matte(0x66B9A1)
    static let sofaBack = matte(0x4D9E8B)
    static let cushion = matte(0x7CCAB2)
    static let shirt = matte(0xC983B8)
    static let trousers = matte(0x516A89)
    static let skin = matte(0xB87355)
    static let hair = matte(0x302A2B)
    static let shoe = matte(0xF3C66E)
    static let dark = matte(0x251F23)
    static let wood = matte(0xA8754F)
    static let tvFrame = matte(0x26333B)
    static let screen = matte(0x88C7D8)
    static let brass = matte(0xD5A955)
    static let lampShade = matte(0xF7E0A0)
    static let mug = matte(0xF5F0E8)
    static let wine = matte(0x8E2946, alpha: 0.86)
    static let glass = matte(0xD6E7E5, alpha: 0.58)
    static let paper = matte(0xF3E8DA)
    static let phone = matte(0x253F51)
    static let sun = matte(0xF2C66D)
    static let coral = matte(0xE98772)
    static let sky = matte(0x8BC6D5)
    static let yoga = matte(0xA782C0)
    static let canvas = matte(0xF4E4C8)
    static let plant = matte(0x4D9D6C)

    private static func matte(_ hex: UInt32, alpha: CGFloat = 1) -> SimpleMaterial {
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 8) & 0xff) / 255
        let blue = CGFloat(hex & 0xff) / 255
        return SimpleMaterial(
            color: UIColor(red: red, green: green, blue: blue, alpha: alpha),
            roughness: 0.78,
            isMetallic: false
        )
    }
}
