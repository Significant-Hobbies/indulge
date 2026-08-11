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
        case avatarShadow
        case torso
        case pelvis
        case head
        case leftArm
        case rightArm
        case leftForearm
        case rightForearm
        case leftHand
        case rightHand
        case leftLeg
        case rightLeg
        case leftKnee
        case rightKnee
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
        root.addChild(makeAvatarShadow())
        root.addChild(makeAvatar())
        root.addChild(makePossibleWorld())
        root.addChild(makeCamera())
        root.addChild(makeLighting())

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
            SIMD3<Float>(-0.65, sofaVisible ? -0.43 : -1.22, 0.16),
            SIMD3<Float>(-1.08, -0.43, -0.52),
            SIMD3<Float>(repeating: progress)
        )
        set(
            role: .sofa,
            in: root,
            transform: transform(
                position: sofaPosition,
                rotation: simd_quatf(angle: -0.10, axis: [0, 1, 0]),
                scale: sofaVisible ? max(0.04, 1 - progress * 0.96) : 0.04
            ),
            duration: duration
        )

        let televisionVisible = assembly.rawValue >= SceneAssemblyStage.televisionArrived.rawValue
        let televisionPosition = simd_mix(
            SIMD3<Float>(1.18, televisionVisible ? -0.66 : 0.55, -0.22),
            SIMD3<Float>(1.42, -0.66, -0.58),
            SIMD3<Float>(repeating: progress)
        )
        set(
            role: .television,
            in: root,
            transform: transform(
                position: televisionPosition,
                rotation: simd_quatf(angle: -0.34, axis: [0, 1, 0]),
                scale: televisionVisible ? max(0.04, 1 - progress * 0.96) : 0.04
            ),
            duration: duration
        )

        let lampVisible = assembly == .settled
        set(
            role: .lamp,
            in: root,
            transform: transform(
                position: [-1.48, lampVisible ? -0.475 : 0.45, 0.12],
                scale: lampVisible ? max(0.04, 1 - progress * 0.96) : 0.04
            ),
            duration: duration
        )

        applyAvatarPose(
            root: root,
            seated: assembly.rawValue >= SceneAssemblyStage.seated.rawValue,
            possibleProgress: progress,
            ambientPulse: ambientPulse,
            holdingCompanion: companion != nil,
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
            return "Your character stands with more room for books, movement, creativity, plants, and connection."
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
        holdingCompanion: Bool,
        duration: TimeInterval
    ) {
        guard let avatar = root.findEntity(named: Role.avatar.rawValue) else { return }
        let basePosition: SIMD3<Float> = seated ? [-0.53, -0.40, 0.43] : [-0.30, -0.17, 0.08]
        let possiblePosition = SIMD3<Float>(0.05, -0.17, -0.05)
        var position = simd_mix(basePosition, possiblePosition, SIMD3<Float>(repeating: possibleProgress))
        position.y += ambientPulse * 0.012 * (1 - possibleProgress)
        move(avatar, to: transform(position: position), duration: duration)

        if let shadow = root.findEntity(named: Role.avatarShadow.rawValue) {
            let shadowPosition = simd_mix(
                SIMD3<Float>(basePosition.x, -0.715, basePosition.z + 0.03),
                SIMD3<Float>(possiblePosition.x, -0.715, possiblePosition.z + 0.03),
                SIMD3<Float>(repeating: possibleProgress)
            )
            move(
                shadow,
                to: transform(position: shadowPosition, scale: 1.08 - possibleProgress * 0.20),
                duration: duration
            )
        }

        let seatedWeight: Float = seated ? 1 - possibleProgress : 0
        let standingWeight = 1 - seatedWeight
        let leftHip = rotation(x: -1.25 * seatedWeight - 0.04 * standingWeight, z: -0.035)
        let rightHip = rotation(x: -1.18 * seatedWeight - 0.03 * standingWeight, z: 0.035)
        setRotation(role: .leftLeg, in: avatar, rotation: leftHip, duration: duration)
        setRotation(role: .rightLeg, in: avatar, rotation: rightHip, duration: duration)
        setRotation(role: .leftKnee, in: avatar, rotation: rotation(x: 1.12 * seatedWeight), duration: duration)
        setRotation(role: .rightKnee, in: avatar, rotation: rotation(x: 1.06 * seatedWeight), duration: duration)

        let openArm = 0.62 * possibleProgress
        let heldOffset: Float = holdingCompanion ? 0.12 * seatedWeight : 0
        setRotation(
            role: .leftArm,
            in: avatar,
            rotation: rotation(x: -0.58 * seatedWeight - 0.10 * standingWeight, z: -openArm - 0.04),
            duration: duration
        )
        setRotation(
            role: .rightArm,
            in: avatar,
            rotation: rotation(x: -0.66 * seatedWeight - 0.10 * standingWeight - heldOffset, z: openArm + 0.04),
            duration: duration
        )
        setRotation(
            role: .leftForearm,
            in: avatar,
            rotation: rotation(x: 0.34 * seatedWeight, z: -0.16 * seatedWeight),
            duration: duration
        )
        setRotation(
            role: .rightForearm,
            in: avatar,
            rotation: rotation(
                x: (holdingCompanion ? 0.52 : 0.34) * seatedWeight,
                z: (holdingCompanion ? 0.42 : 0.18) * seatedWeight
            ),
            duration: duration
        )
        setRotation(role: .torso, in: avatar, rotation: rotation(x: -0.08 * seatedWeight), duration: duration)
        setRotation(role: .head, in: avatar, rotation: rotation(y: -0.16 * seatedWeight), duration: duration)
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
            case .wineGlass: [0, -0.02, 0.045]
            case .mug: [0, 0.015, 0.045]
            case .smoking: [0, 0.005, 0.10]
            case .phone: [0, 0.01, 0.055]
            default: .zero
            }
            let visibleScale: Float = switch role {
            case .wineGlass: 0.72
            case .mug: 0.84
            case .smoking: 0.76
            case .phone: 0.82
            default: 1
            }
            let propRotation: simd_quatf = switch role {
            case .wineGlass, .mug:
                rotation(z: seated ? -0.42 : 0)
            case .phone:
                rotation(x: -0.16, z: seated ? -0.32 : 0)
            default:
                rotation(z: seated ? -0.42 : 0)
            }
            move(
                entity,
                to: transform(
                    position: position,
                    rotation: propRotation,
                    scale: visible ? visibleScale : 0.001
                ),
                duration: duration
            )
            entity.components.set(OpacityComponent(opacity: visible ? 1 : 0))
        }
    }

    private static func makeStage() -> Entity {
        let stage = Entity()
        stage.name = Role.stage.rawValue
        stage.addChild(box(size: [3.75, 0.18, 2.42], radius: 0.09, material: Materials.stage, position: .zero))
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
        let shadow = oval(size: [1.62, 0.018, 0.58], material: Materials.shadow, position: [0, -0.305, 0.02])
        shadow.name = "sofa-contact-shadow"
        sofa.addChild(shadow)
        return sofa
    }

    private static func makeTelevision() -> Entity {
        let television = Entity()
        television.name = Role.television.rawValue
        television.addChild(box(size: [1.12, 0.70, 0.10], radius: 0.07, material: Materials.tvFrame, position: [0, 0.66, 0]))
        television.addChild(box(size: [0.96, 0.55, 0.02], radius: 0.04, material: Materials.screen, position: [0, 0.66, 0.061]))
        television.addChild(box(size: [0.10, 0.52, 0.10], radius: 0.04, material: Materials.wood, position: [0, 0.22, 0]))
        television.addChild(box(size: [0.70, 0.10, 0.38], radius: 0.04, material: Materials.wood, position: [0, -0.02, 0]))
        let shadow = oval(size: [0.74, 0.016, 0.42], material: Materials.shadow, position: [0, -0.075, 0.01])
        shadow.name = "television-contact-shadow"
        television.addChild(shadow)
        return television
    }

    private static func makeLamp() -> Entity {
        let lamp = Entity()
        lamp.name = Role.lamp.rawValue
        lamp.addChild(box(size: [0.08, 1.16, 0.08], radius: 0.03, material: Materials.brass, position: [0, 0.34, 0]))
        lamp.addChild(box(size: [0.42, 0.34, 0.42], radius: 0.11, material: Materials.lampShade, position: [0, 0.96, 0]))
        lamp.addChild(box(size: [0.42, 0.07, 0.42], radius: 0.03, material: Materials.brass, position: [0, -0.22, 0]))
        let shadow = oval(size: [0.48, 0.016, 0.46], material: Materials.shadow, position: [0, -0.26, 0])
        shadow.name = "lamp-contact-shadow"
        lamp.addChild(shadow)
        return lamp
    }

    private static func makeAvatarShadow() -> Entity {
        let shadow = oval(size: [0.62, 0.016, 0.38], material: Materials.shadow, position: .zero)
        shadow.name = Role.avatarShadow.rawValue
        return shadow
    }

    private static func makeAvatar() -> Entity {
        let avatar = Entity()
        avatar.name = Role.avatar.rawValue

        let pelvis = oval(size: [0.40, 0.27, 0.29], material: Materials.trousers, position: [0, 0.47, 0])
        pelvis.name = Role.pelvis.rawValue
        avatar.addChild(pelvis)

        let torso = oval(size: [0.52, 0.64, 0.31], material: Materials.shirt, position: [0, 0.84, 0])
        torso.name = Role.torso.rawValue
        avatar.addChild(torso)

        avatar.addChild(oval(size: [0.16, 0.18, 0.16], material: Materials.skin, position: [0, 1.14, 0]))

        let head = Entity()
        head.name = Role.head.rawValue
        head.position = [0, 1.30, 0]
        head.addChild(oval(size: [0.34, 0.40, 0.34], material: Materials.skin, position: .zero))
        head.addChild(oval(size: [0.35, 0.17, 0.33], material: Materials.hair, position: [0, 0.17, -0.01]))
        head.addChild(oval(size: [0.052, 0.066, 0.024], material: Materials.dark, position: [-0.07, 0.025, 0.17]))
        head.addChild(oval(size: [0.052, 0.066, 0.024], material: Materials.dark, position: [0.07, 0.025, 0.17]))
        head.addChild(oval(size: [0.073, 0.032, 0.024], material: Materials.coral, position: [0, -0.085, 0.17]))
        avatar.addChild(head)

        avatar.addChild(makeArm(side: -1))
        avatar.addChild(makeArm(side: 1))
        avatar.addChild(makeLeg(side: -1))
        avatar.addChild(makeLeg(side: 1))

        if let socket = avatar.findEntity(named: Role.rightHandSocket.rawValue) {
            let mug = makeMug()
            mug.name = Role.mug.rawValue
            socket.addChild(mug)
            let wine = makeWineGlass()
            wine.name = Role.wineGlass.rawValue
            socket.addChild(wine)
            let smoking = box(size: [0.025, 0.025, 0.23], radius: 0.01, material: Materials.paper, position: .zero)
            smoking.name = Role.smoking.rawValue
            socket.addChild(smoking)
            let phone = box(size: [0.15, 0.28, 0.025], radius: 0.03, material: Materials.phone, position: .zero)
            phone.name = Role.phone.rawValue
            socket.addChild(phone)
        }

        return avatar
    }

    private static func makePossibleWorld() -> Entity {
        let world = Entity()
        world.name = Role.possibleWorld.rawValue

        let arch = Entity()
        arch.addChild(box(size: [0.16, 1.45, 0.16], radius: 0.07, material: Materials.sun, position: [-1.25, -0.065, -0.35]))
        arch.addChild(box(size: [0.16, 1.45, 0.16], radius: 0.07, material: Materials.sun, position: [1.25, -0.065, -0.35]))
        arch.addChild(box(size: [2.66, 0.16, 0.16], radius: 0.07, material: Materials.sun, position: [0, 0.645, -0.35]))
        arch.addChild(possibleContactShadow(name: "arch-contact-shadow", size: [2.72, 0.014, 0.25], position: [0, -0.795, -0.35]))
        world.addChild(arch)

        let bookStack = Entity()
        bookStack.addChild(box(size: [0.48, 0.10, 0.34], radius: 0.03, material: Materials.coral, position: [-1.02, -0.74, 0.15]))
        bookStack.addChild(box(size: [0.42, 0.10, 0.32], radius: 0.03, material: Materials.sun, position: [-1.02, -0.63, 0.15]))
        bookStack.addChild(box(size: [0.46, 0.10, 0.34], radius: 0.03, material: Materials.sky, position: [-1.02, -0.52, 0.15]))
        bookStack.addChild(possibleContactShadow(name: "books-contact-shadow", size: [0.56, 0.014, 0.40], position: [-1.02, -0.795, 0.15]))
        world.addChild(bookStack)

        let making = Entity()
        making.addChild(box(size: [0.78, 0.035, 1.20], radius: 0.02, material: Materials.yoga, position: [0.98, -0.7725, 0.12]))
        making.addChild(box(size: [0.08, 0.95, 0.08], radius: 0.03, material: Materials.wood, position: [0.78, -0.315, -0.12]))
        making.addChild(box(size: [0.76, 0.62, 0.06], radius: 0.03, material: Materials.canvas, position: [0.78, 0.025, -0.10]))
        making.addChild(possibleContactShadow(name: "making-contact-shadow", size: [0.92, 0.014, 1.28], position: [0.92, -0.795, 0.08]))
        world.addChild(making)

        let plant = Entity()
        plant.addChild(box(size: [0.30, 0.28, 0.30], radius: 0.08, material: Materials.coral, position: [-1.18, -0.65, -0.42]))
        plant.addChild(oval(size: [0.22, 0.55, 0.12], material: Materials.plant, position: [-1.30, -0.25, -0.42]))
        plant.addChild(oval(size: [0.22, 0.50, 0.12], material: Materials.plant, position: [-1.05, -0.28, -0.42]))
        plant.addChild(possibleContactShadow(name: "plant-contact-shadow", size: [0.42, 0.014, 0.38], position: [-1.18, -0.795, -0.42]))
        world.addChild(plant)

        let connection = Entity()
        connection.addChild(oval(size: [0.20, 0.25, 0.20], material: Materials.skin, position: [-1.30, -0.275, -0.48]))
        connection.addChild(oval(size: [0.27, 0.39, 0.22], material: Materials.sky, position: [-1.30, -0.595, -0.48]))
        connection.addChild(oval(size: [0.20, 0.25, 0.20], material: Materials.skin, position: [-0.98, -0.275, -0.48]))
        connection.addChild(oval(size: [0.27, 0.39, 0.22], material: Materials.coral, position: [-0.98, -0.595, -0.48]))
        connection.addChild(possibleContactShadow(name: "connection-contact-shadow", size: [0.68, 0.014, 0.30], position: [-1.14, -0.795, -0.48]))
        world.addChild(connection)

        return world
    }

    private static func possibleContactShadow(
        name: String,
        size: SIMD3<Float>,
        position: SIMD3<Float>
    ) -> Entity {
        let shadow = oval(size: size, material: Materials.shadow, position: position)
        shadow.name = name
        return shadow
    }

    private static func makeCamera() -> Entity {
        let camera = PerspectiveCamera()
        camera.name = Role.camera.rawValue
        camera.camera.fieldOfViewInDegrees = 34
        camera.look(at: [0, 0.22, 0], from: [3.7, 2.45, 5.25], relativeTo: nil)
        return camera
    }

    private static func makeLighting() -> Entity {
        let lighting = Entity()
        lighting.name = "scene-lighting"
        lighting.addChild(
            directionalLight(
                name: "key-light",
                color: .init(red: 1.0, green: 0.92, blue: 0.80, alpha: 1),
                intensity: 3_000,
                from: [-2.5, 4.8, 4.0]
            )
        )
        lighting.addChild(
            directionalLight(
                name: "sky-fill",
                color: .init(red: 0.66, green: 0.86, blue: 0.96, alpha: 1),
                intensity: 920,
                from: [3.4, 2.2, 4.8]
            )
        )
        lighting.addChild(
            directionalLight(
                name: "warm-rim",
                color: .init(red: 1.0, green: 0.70, blue: 0.42, alpha: 1),
                intensity: 640,
                from: [-1.0, 2.4, -4.0]
            )
        )
        return lighting
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

    private static func makeArm(side: Float) -> Entity {
        let shoulder = Entity()
        shoulder.name = side < 0 ? Role.leftArm.rawValue : Role.rightArm.rawValue
        shoulder.position = [side * 0.29, 0.99, 0]
        shoulder.addChild(oval(size: [0.22, 0.22, 0.23], material: Materials.shirt, position: [0, -0.06, 0]))
        shoulder.addChild(oval(size: [0.15, 0.34, 0.15], material: Materials.skin, position: [0, -0.21, 0]))

        let forearm = Entity()
        forearm.name = side < 0 ? Role.leftForearm.rawValue : Role.rightForearm.rawValue
        forearm.position = [0, -0.38, 0]
        forearm.addChild(oval(size: [0.14, 0.32, 0.14], material: Materials.skin, position: [0, -0.16, 0]))
        forearm.addChild(oval(size: [0.155, 0.155, 0.155], material: Materials.skin, position: [0, -0.34, 0]))

        let hand = Entity()
        hand.name = side < 0 ? Role.leftHand.rawValue : Role.rightHand.rawValue
        hand.position = [0, -0.34, 0]
        let socket = Entity()
        socket.name = side < 0 ? Role.leftHandSocket.rawValue : Role.rightHandSocket.rawValue
        socket.position = [0, 0, 0.11]
        hand.addChild(socket)
        forearm.addChild(hand)
        shoulder.addChild(forearm)
        return shoulder
    }

    private static func makeLeg(side: Float) -> Entity {
        let hip = Entity()
        hip.name = side < 0 ? Role.leftLeg.rawValue : Role.rightLeg.rawValue
        hip.position = [side * 0.15, 0.48, 0]
        hip.addChild(oval(size: [0.20, 0.38, 0.21], material: Materials.trousers, position: [0, -0.18, 0]))

        let knee = Entity()
        knee.name = side < 0 ? Role.leftKnee.rawValue : Role.rightKnee.rawValue
        knee.position = [0, -0.38, 0]
        knee.addChild(oval(size: [0.18, 0.62, 0.18], material: Materials.trousers, position: [0, -0.30, 0]))
        knee.addChild(oval(size: [0.25, 0.13, 0.40], material: Materials.shoe, position: [0, -0.65, 0.12]))
        hip.addChild(knee)
        return hip
    }

    private static func directionalLight(
        name: String,
        color: UIColor,
        intensity: Float,
        from: SIMD3<Float>
    ) -> DirectionalLight {
        let light = DirectionalLight()
        light.name = name
        light.light.color = color
        light.light.intensity = intensity
        light.look(at: [0, 0, 0], from: from, relativeTo: nil)
        return light
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

    private static func setRotation(
        role: Role,
        in root: Entity,
        rotation: simd_quatf,
        duration: TimeInterval
    ) {
        guard let entity = root.findEntity(named: role.rawValue) else { return }
        var target = entity.transform
        target.rotation = rotation
        move(entity, to: target, duration: duration)
    }

    private static func rotation(x: Float = 0, y: Float = 0, z: Float = 0) -> simd_quatf {
        simd_quatf(angle: z, axis: [0, 0, 1])
            * simd_quatf(angle: y, axis: [0, 1, 0])
            * simd_quatf(angle: x, axis: [1, 0, 0])
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
