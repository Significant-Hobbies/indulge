import Foundation
import SwiftData

enum FocusInterruptionSource: String, CaseIterable, Codable, Hashable, Sendable {
  case external
  case drift
  case environment

  var title: String {
    switch self {
    case .external: "External"
    case .drift: "Drift"
    case .environment: "Environment"
    }
  }

  var prompt: String {
    switch self {
    case .external: "Someone or something reached you"
    case .drift: "Your attention moved on its own"
    case .environment: "Your body or surroundings pulled you away"
    }
  }

  var icon: String {
    switch self {
    case .external: "person.2.fill"
    case .drift: "arrow.trianglehead.branch"
    case .environment: "leaf.fill"
    }
  }
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

  var title: String {
    switch self {
    case .personOrCall: "Person or call"
    case .message: "Message or notification"
    case .difficultTask: "The work became difficult"
    case .randomThought: "A thought pulled me away"
    case .temptingApp: "I opened something tempting"
    case .noise: "Noise or surroundings"
    case .bodyNeed: "Hunger, discomfort, or bathroom"
    case .other: "Something else"
    }
  }

  var patternPhrase: String {
    switch self {
    case .personOrCall: "a person or call reaching me"
    case .message: "a message or notification"
    case .difficultTask: "the work becoming difficult"
    case .randomThought: "a thought pulling me away"
    case .temptingApp: "opening something tempting"
    case .noise: "noise or my surroundings"
    case .bodyNeed: "a body need"
    case .other: "something else"
    }
  }

  var icon: String {
    switch self {
    case .personOrCall: "phone.fill"
    case .message: "message.fill"
    case .difficultTask: "questionmark.diamond.fill"
    case .randomThought: "bubble.left.and.exclamationmark.bubble.right.fill"
    case .temptingApp: "rectangle.stack.fill"
    case .noise: "speaker.wave.2.fill"
    case .bodyNeed: "figure.stand"
    case .other: "ellipsis"
    }
  }
}

enum FocusReturnBlockage: String, CaseIterable, Codable, Hashable, Sendable {
  case urgentDemand
  case temptingContent
  case unclearNextStep
  case emotion
  case fatigue
  case environment
  case notSure

  var title: String {
    switch self {
    case .urgentDemand: "It needed an immediate response"
    case .temptingContent: "The other thing kept pulling me"
    case .unclearNextStep: "I was unsure what to do next"
    case .emotion: "I needed relief from how the work felt"
    case .fatigue: "I was tired"
    case .environment: "The interruption was still around"
    case .notSure: "I’m not sure yet"
    }
  }

  var shortTitle: String {
    switch self {
    case .urgentDemand: "Urgency"
    case .temptingContent: "Tempting content"
    case .unclearNextStep: "Unclear next step"
    case .emotion: "Emotional relief"
    case .fatigue: "Fatigue"
    case .environment: "Environment"
    case .notSure: "Not sure"
    }
  }

  var icon: String {
    switch self {
    case .urgentDemand: "bolt.fill"
    case .temptingContent: "sparkles.rectangle.stack.fill"
    case .unclearNextStep: "signpost.right.and.left.fill"
    case .emotion: "heart.fill"
    case .fatigue: "moon.zzz.fill"
    case .environment: "waveform.path.ecg.rectangle.fill"
    case .notSure: "questionmark"
    }
  }
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

struct FocusSessionSnapshot: Equatable, Sendable {
  let id: UUID
  let intention: String
  let startedAt: Date
  let endedAt: Date?
}

struct FocusInterruptionSnapshot: Equatable, Sendable {
  let id: UUID
  let sessionID: UUID
  let interruptedAt: Date
  let returnedAt: Date?
  let source: FocusInterruptionSource?
  let reason: FocusInterruptionReason?
  let blockage: FocusReturnBlockage?
}

extension FocusSessionRecord {
  var snapshot: FocusSessionSnapshot {
    FocusSessionSnapshot(id: id, intention: intention, startedAt: startedAt, endedAt: endedAt)
  }
}

extension FocusInterruptionRecord {
  var snapshot: FocusInterruptionSnapshot {
    FocusInterruptionSnapshot(
      id: id,
      sessionID: sessionID,
      interruptedAt: interruptedAt,
      returnedAt: returnedAt,
      source: source,
      reason: reason,
      blockage: blockage
    )
  }
}

enum FocusModelContainer {
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
    let configuration: ModelConfiguration
    if let storeURL {
      configuration = ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
    } else if inMemory {
      configuration = ModelConfiguration(
        isStoredInMemoryOnly: true,
        groupContainer: .none,
        cloudKitDatabase: .none
      )
    } else {
      let cloudKitDatabase: ModelConfiguration.CloudKitDatabase
      switch cloudSync {
      case .localOnly:
        cloudKitDatabase = .none
      case .privateDatabase(let containerIdentifier):
        cloudKitDatabase = .private(containerIdentifier)
      }
      configuration = ModelConfiguration(
        isStoredInMemoryOnly: false,
        groupContainer: .none,
        cloudKitDatabase: cloudKitDatabase
      )
    }
    let schema = Schema(versionedSchema: IndulgeDataSchemaV1.self)
    return try ModelContainer(
      for: schema,
      migrationPlan: IndulgeDataMigrationPlan.self,
      configurations: configuration
    )
  }

  static func makeLegacyStore(at storeURL: URL) throws -> ModelContainer {
    try ModelContainer(
      for: FocusSessionRecord.self,
      FocusInterruptionRecord.self,
      configurations: ModelConfiguration(url: storeURL, cloudKitDatabase: .none)
    )
  }
}

@MainActor
struct FocusRepository {
  let context: ModelContext

  func sessions() throws -> [FocusSessionRecord] {
    let descriptor = FetchDescriptor<FocusSessionRecord>(
      sortBy: [SortDescriptor(\FocusSessionRecord.startedAt, order: .reverse)]
    )
    return try context.fetch(descriptor)
  }

  func interruptions() throws -> [FocusInterruptionRecord] {
    let descriptor = FetchDescriptor<FocusInterruptionRecord>(
      sortBy: [SortDescriptor(\FocusInterruptionRecord.interruptedAt, order: .reverse)]
    )
    return try context.fetch(descriptor)
  }

  func activeSession() throws -> FocusSessionRecord? {
    try sessions().first(where: { $0.endedAt == nil })
  }

  func activeInterruption(for sessionID: UUID) throws -> FocusInterruptionRecord? {
    try interruptions().first(where: { $0.sessionID == sessionID && $0.returnedAt == nil })
  }

  @discardableResult
  func startSession(intention: String, at date: Date = .now) throws -> FocusSessionRecord {
    try repairActiveRecords(at: date)
    if let active = try activeSession() { return active }

    let session = FocusSessionRecord(
      intention: intention.trimmingCharacters(in: .whitespacesAndNewlines),
      startedAt: date
    )
    context.insert(session)
    try context.save()
    return session
  }

  @discardableResult
  func beginInterruption(in session: FocusSessionRecord, at date: Date = .now) throws
    -> FocusInterruptionRecord
  {
    if let active = try activeInterruption(for: session.id) { return active }
    let interruption = FocusInterruptionRecord(sessionID: session.id, interruptedAt: date)
    context.insert(interruption)
    try context.save()
    return interruption
  }

  func classify(
    _ interruption: FocusInterruptionRecord,
    source: FocusInterruptionSource,
    reason: FocusInterruptionReason,
    note: String
  ) throws {
    interruption.source = source
    interruption.reason = reason
    interruption.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    try context.save()
  }

  func returnToFocus(
    from interruption: FocusInterruptionRecord,
    blockage: FocusReturnBlockage,
    at date: Date = .now
  ) throws {
    interruption.blockage = blockage
    interruption.returnedAt = max(date, interruption.interruptedAt)
    try context.save()
  }

  func endSession(_ session: FocusSessionRecord, at date: Date = .now) throws {
    guard try activeInterruption(for: session.id) == nil else { return }
    session.endedAt = max(date, session.startedAt)
    try context.save()
  }

  func repairActiveRecords(at date: Date = .now) throws {
    try deduplicateEvents()

    let openSessions = try sessions().filter { $0.endedAt == nil }
    if openSessions.count > 1 {
      let newest = openSessions[0]
      for older in openSessions.dropFirst() {
        older.endedAt = max(older.startedAt, newest.startedAt)
      }
    }

    let openInterruptions = try interruptions().filter { $0.returnedAt == nil }
    let grouped = Dictionary(grouping: openInterruptions, by: \FocusInterruptionRecord.sessionID)
    for values in grouped.values where values.count > 1 {
      let newest = values[0]
      for older in values.dropFirst() {
        older.returnedAt = max(older.interruptedAt, newest.interruptedAt)
      }
    }

    let sessionIDs = Set(try sessions().map(\.id))
    for orphan in try interruptions() where !sessionIDs.contains(orphan.sessionID) {
      context.delete(orphan)
    }
    try context.save()
  }

  func deduplicateEvents() throws {
    for duplicates in Dictionary(grouping: try sessions(), by: \FocusSessionRecord.id).values
    where duplicates.count > 1 {
      let ordered = duplicates.sorted { lhs, rhs in
        let lhsScore = (lhs.endedAt == nil ? 0 : 2) + (lhs.intention.isEmpty ? 0 : 1)
        let rhsScore = (rhs.endedAt == nil ? 0 : 2) + (rhs.intention.isEmpty ? 0 : 1)
        if lhsScore != rhsScore { return lhsScore > rhsScore }
        return lhs.startedAt < rhs.startedAt
      }
      guard let retained = ordered.first else { continue }
      for duplicate in ordered.dropFirst() {
        if retained.intention.isEmpty { retained.intention = duplicate.intention }
        retained.startedAt = min(retained.startedAt, duplicate.startedAt)
        if let duplicateEnd = duplicate.endedAt {
          retained.endedAt = max(retained.endedAt ?? duplicateEnd, duplicateEnd)
        }
        context.delete(duplicate)
      }
    }

    for duplicates in Dictionary(grouping: try interruptions(), by: \FocusInterruptionRecord.id)
      .values where duplicates.count > 1
    {
      let ordered = duplicates.sorted { lhs, rhs in
        let lhsScore = [
          lhs.returnedAt != nil, lhs.source != nil, lhs.reason != nil,
          lhs.blockage != nil, !lhs.note.isEmpty,
        ].filter { $0 }.count
        let rhsScore = [
          rhs.returnedAt != nil, rhs.source != nil, rhs.reason != nil,
          rhs.blockage != nil, !rhs.note.isEmpty,
        ].filter { $0 }.count
        if lhsScore != rhsScore { return lhsScore > rhsScore }
        return lhs.interruptedAt < rhs.interruptedAt
      }
      guard let retained = ordered.first else { continue }
      for duplicate in ordered.dropFirst() {
        retained.interruptedAt = min(retained.interruptedAt, duplicate.interruptedAt)
        if let duplicateReturn = duplicate.returnedAt {
          retained.returnedAt = max(retained.returnedAt ?? duplicateReturn, duplicateReturn)
        }
        if retained.source == nil { retained.source = duplicate.source }
        if retained.reason == nil { retained.reason = duplicate.reason }
        if retained.blockage == nil { retained.blockage = duplicate.blockage }
        if retained.note.isEmpty { retained.note = duplicate.note }
        context.delete(duplicate)
      }
    }
  }
}
