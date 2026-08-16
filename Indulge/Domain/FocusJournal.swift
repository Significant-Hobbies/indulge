import Foundation
import SwiftData

enum FocusInterruptionSource: String, CaseIterable, Codable, Hashable, Sendable {
  case external
  case drift
  case environment
}

enum FocusInterruptionReason: String, CaseIterable, Codable, Hashable, Sendable {
  case personOrCall
  case message
  case difficultTask
  case randomThought
  case temptingApp
  case noise
  case bodyNeed
  case other
}

enum FocusReturnBlockage: String, CaseIterable, Codable, Hashable, Sendable {
  case urgentDemand
  case temptingContent
  case unclearNextStep
  case emotion
  case fatigue
  case environment
  case notSure
}

@Model
final class FocusSessionRecord {
  #Index<FocusSessionRecord>([\.id])

  var id: UUID = UUID()
  var intention: String = ""
  var startedAt: Date = Date.now
  var endedAt: Date?

  init(
    id: UUID = UUID(),
    intention: String = "",
    startedAt: Date = .now,
    endedAt: Date? = nil
  ) {
    self.id = id
    self.intention = intention
    self.startedAt = startedAt
    self.endedAt = endedAt
  }
}

@Model
final class FocusInterruptionRecord {
  #Index<FocusInterruptionRecord>([\.id], [\.sessionID])

  var id: UUID = UUID()
  var sessionID: UUID = UUID()
  var interruptedAt: Date = Date.now
  var returnedAt: Date?
  var sourceRawValue: String?
  var reasonRawValue: String?
  var blockageRawValue: String?
  var note: String = ""

  init(
    id: UUID = UUID(),
    sessionID: UUID,
    interruptedAt: Date = .now,
    returnedAt: Date? = nil,
    source: FocusInterruptionSource? = nil,
    reason: FocusInterruptionReason? = nil,
    blockage: FocusReturnBlockage? = nil,
    note: String = ""
  ) {
    self.id = id
    self.sessionID = sessionID
    self.interruptedAt = interruptedAt
    self.returnedAt = returnedAt
    sourceRawValue = source?.rawValue
    reasonRawValue = reason?.rawValue
    blockageRawValue = blockage?.rawValue
    self.note = note
  }

  var source: FocusInterruptionSource? {
    get { sourceRawValue.flatMap(FocusInterruptionSource.init(rawValue:)) }
    set { sourceRawValue = newValue?.rawValue }
  }

  var reason: FocusInterruptionReason? {
    get { reasonRawValue.flatMap(FocusInterruptionReason.init(rawValue:)) }
    set { reasonRawValue = newValue?.rawValue }
  }

  var blockage: FocusReturnBlockage? {
    get { blockageRawValue.flatMap(FocusReturnBlockage.init(rawValue:)) }
    set { blockageRawValue = newValue?.rawValue }
  }

  var isFullyClassified: Bool {
    source != nil && reason != nil
  }

  var isComplete: Bool {
    returnedAt != nil && isFullyClassified && blockage != nil
  }
}

enum IndulgeModelContainer {
  static let privateCloudKitContainerIdentifier = "iCloud.com.significanthobbies.indulge"

  enum CloudSyncSelection: Equatable, Sendable {
    case localOnly
    case privateDatabase(containerIdentifier: String)

    static var applicationDefault: Self {
      #if targetEnvironment(simulator)
        .localOnly
      #else
        .privateDatabase(containerIdentifier: privateCloudKitContainerIdentifier)
      #endif
    }
  }

  static func make(
    inMemory: Bool = false,
    storeURL: URL? = nil,
    cloudSync: CloudSyncSelection = .applicationDefault
  ) throws -> ModelContainer {
    let selectedConfiguration = configuration(
      inMemory: inMemory,
      storeURL: storeURL,
      cloudSync: cloudSync
    )
    let schema = Schema(versionedSchema: IndulgeDataSchemaV2.self)
    do {
      return try ModelContainer(
        for: schema,
        migrationPlan: IndulgeDataMigrationPlan.self,
        configurations: selectedConfiguration
      )
    } catch {
      guard storeURL != nil else { throw error }

      // Builds before the versioned schema shipped wrote an unversioned, focus-only
      // local store. Opening it once through V1 stamps the known schema metadata;
      // the normal staged V1 -> V2 migration can then preserve it.
      _ = try ModelContainer(
        for: Schema(versionedSchema: IndulgeDataSchemaV1.self),
        configurations: configuration(
          inMemory: inMemory,
          storeURL: storeURL,
          cloudSync: cloudSync
        )
      )
      return try ModelContainer(
        for: schema,
        migrationPlan: IndulgeDataMigrationPlan.self,
        configurations: configuration(
          inMemory: inMemory,
          storeURL: storeURL,
          cloudSync: cloudSync
        )
      )
    }
  }

  private static func configuration(
    inMemory: Bool,
    storeURL: URL?,
    cloudSync: CloudSyncSelection
  ) -> ModelConfiguration {
    if let storeURL {
      return ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
    }
    if inMemory {
      return ModelConfiguration(
        isStoredInMemoryOnly: true,
        groupContainer: .none,
        cloudKitDatabase: .none
      )
    }

    let cloudKitDatabase: ModelConfiguration.CloudKitDatabase
    switch cloudSync {
    case .localOnly:
      cloudKitDatabase = .none
    case .privateDatabase(let containerIdentifier):
      cloudKitDatabase = .private(containerIdentifier)
    }
    return ModelConfiguration(
      isStoredInMemoryOnly: false,
      groupContainer: .none,
      cloudKitDatabase: cloudKitDatabase
    )
  }

  static func makeLegacyStore(at storeURL: URL) throws -> ModelContainer {
    try ModelContainer(
      for: FocusSessionRecord.self,
      FocusInterruptionRecord.self,
      configurations: ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
    )
  }

  static func makeV1Store(at storeURL: URL) throws -> ModelContainer {
    try ModelContainer(
      for: Schema(versionedSchema: IndulgeDataSchemaV1.self),
      configurations: ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
    )
  }
}
