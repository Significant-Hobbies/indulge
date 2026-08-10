import Foundation

enum IndulgenceCatalog {
    static let companionRecipes: [CompanionID: CompanionRecipe] = [
        .phone: .init(id: .phone, preferredSocket: .rightHand, allowedSockets: [.rightHand, .leftHand, .lap]),
        .mug: .init(id: .mug, preferredSocket: .rightHand, allowedSockets: [.rightHand, .leftHand, .sideTable]),
        .wineGlass: .init(id: .wineGlass, preferredSocket: .rightHand, allowedSockets: [.rightHand, .leftHand, .sideTable]),
        .smoking: .init(id: .smoking, preferredSocket: .leftHand, allowedSockets: [.leftHand, .rightHand]),
        .snackBowl: .init(id: .snackBowl, preferredSocket: .lap, allowedSockets: [.lap, .sideTable]),
        .controller: .init(id: .controller, preferredSocket: .lap, allowedSockets: [.lap, .leftHand, .rightHand]),
        .headphones: .init(id: .headphones, preferredSocket: .sideTable, allowedSockets: [.sideTable, .lap])
    ]

    static let recipes: [IndulgenceRecipe] = [
        recipe(.television, "Watching TV", "Watching", .sofaSeated, .livingRoom, .seatedWide, [.snackBowl], [.breathe, .screenGlow], watchingArrival),
        recipe(.streaming, "Streaming a series", "Watching", .sofaSeated, .livingRoom, .seatedWide, [.snackBowl], [.breathe, .screenGlow], watchingArrival),
        recipe(.films, "Watching films", "Watching", .sofaSeated, .livingRoom, .seatedWide, [], [.breathe, .screenGlow], watchingArrival),
        recipe(.shortVideo, "Short videos", "Scrolling", .sofaSeated, .livingRoom, .intimate, [.phone], [.breathe], compactArrival),
        recipe(.socialFeeds, "Social feeds", "Scrolling", .sofaSeated, .livingRoom, .intimate, [.phone], [.breathe], compactArrival),
        recipe(.newsScroll, "Reading the news", "Scrolling", .chairSeated, .desk, .desk, [.phone, .mug], [.steam], compactArrival),
        recipe(.webBrowsing, "Browsing the web", "Browsing", .chairSeated, .desk, .desk, [.mug], [.screenGlow, .steam], deskArrival),
        recipe(.rabbitHoles, "Going down rabbit holes", "Browsing", .chairSeated, .desk, .desk, [.mug], [.screenGlow], deskArrival),
        recipe(.consoleGaming, "Console gaming", "Gaming", .sofaSeated, .gaming, .seatedWide, [.controller], [.screenGlow, .footTap], watchingArrival),
        recipe(.handheldGaming, "Handheld gaming", "Gaming", .crossLegged, .gaming, .intimate, [.controller], [.footTap], compactArrival),
        recipe(.music, "Listening to music", "Listening", .reclined, .listening, .seatedWide, [.headphones], [.headNod], relaxedArrival),
        recipe(.podcasts, "Listening to podcasts", "Listening", .reclined, .listening, .seatedWide, [.headphones], [.breathe], relaxedArrival),
        recipe(.snacking, "Snacking", "Eating & drinking", .sofaSeated, .livingRoom, .intimate, [.snackBowl], [.breathe], compactArrival),
        recipe(.takeaway, "Ordering takeaway", "Eating & drinking", .chairSeated, .cafe, .intimate, [.phone], [.breathe], compactArrival),
        recipe(.sweets, "Having something sweet", "Eating & drinking", .chairSeated, .cafe, .intimate, [], [.breathe], compactArrival),
        recipe(.coffee, "Having coffee", "Eating & drinking", .chairSeated, .cafe, .intimate, [.mug], [.steam], compactArrival),
        recipe(.alcohol, "Having a drink", "Eating & drinking", .sofaSeated, .livingRoom, .intimate, [], [.breathe], compactArrival),
        recipe(.onlineShopping, "Shopping online", "Shopping", .chairSeated, .desk, .desk, [.phone], [.screenGlow], deskArrival),
        recipe(.windowShopping, "Browsing shops", "Shopping", .standing, .social, .fullBody, [.phone], [.conversation], standingArrival),
        recipe(.napping, "Taking a nap", "Resting", .reclined, .bedroom, .seatedWide, [], [.breathe], relaxedArrival),
        recipe(.lyingIn, "Lying in", "Resting", .reclined, .bedroom, .seatedWide, [.phone], [.breathe], relaxedArrival),
        recipe(.texting, "Texting", "Connection", .sofaSeated, .livingRoom, .intimate, [.phone], [.breathe], compactArrival),
        recipe(.videoCalls, "Video calling", "Connection", .chairSeated, .desk, .desk, [.phone, .mug], [.conversation], deskArrival),
        recipe(.hangingOut, "Hanging out", "Connection", .sofaSeated, .social, .seatedWide, [], [.conversation], watchingArrival)
    ]

    static let byID = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })

    static let defaultCompanions: [CompanionID] = companionRecipes.values
        .filter { !$0.explicitOnly }
        .map(\.id)
        .sorted { $0.rawValue < $1.rawValue }

    private static let watchingArrival: [ArrivalPhase] = [.stage, .environment, .characterResponse, .primaryObject, .companion, .settle]
    private static let deskArrival: [ArrivalPhase] = [.stage, .environment, .primaryObject, .characterResponse, .companion, .settle]
    private static let compactArrival: [ArrivalPhase] = [.stage, .characterResponse, .companion, .settle]
    private static let relaxedArrival: [ArrivalPhase] = [.stage, .environment, .characterResponse, .settle]
    private static let standingArrival: [ArrivalPhase] = [.stage, .environment, .characterResponse, .settle]

    private static func recipe(
        _ id: IndulgenceID,
        _ title: String,
        _ family: String,
        _ pose: CharacterPose,
        _ environment: EnvironmentCluster,
        _ camera: CameraTarget,
        _ defaults: [CompanionID],
        _ loops: Set<AmbientLoop>,
        _ phases: [ArrivalPhase]
    ) -> IndulgenceRecipe {
        IndulgenceRecipe(
            id: id,
            title: title,
            familyLabel: family,
            basePose: pose,
            environment: environment,
            cameraTarget: camera,
            defaultCompanions: defaults,
            ambientLoops: loops,
            arrivalPhases: phases
        )
    }
}
