import CryptoKit
import Foundation
import Observation
import PersonalSyncKit
import SwiftData

@MainActor
@Observable
final class HabitsPlatformSync {
  private let connection: PersonalPlatformConnection?
  let account: PersonalWebSignInModel?
  private(set) var isSyncing = false
  private(set) var message: String?

  init(enabled: Bool) {
    guard enabled else {
      connection = nil
      account = nil
      return
    }

    let defaults = UserDefaults.standard
    let deviceKey = "personal-platform-device-id"
    let deviceId = defaults.string(forKey: deviceKey) ?? UUID().uuidString.lowercased()
    defaults.set(deviceId, forKey: deviceKey)
    let supportDirectory = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first!
    let connection = try? PersonalPlatformConnection(
      domain: .habits,
      keychainService: "com.significanthobbies.indulge",
      supportDirectory: supportDirectory,
      deviceId: deviceId
    )
    self.connection = connection
    account = connection.map {
      PersonalWebSignInModel(identity: $0.identity, callbackScheme: "habits")
    }
  }

  func restoreAndSync(context: ModelContext) async {
    await account?.restore()
    await synchronize(context: context)
  }

  func synchronize(context: ModelContext, announcing: Bool = false) async {
    guard let connection, !isSyncing else { return }
    isSyncing = true
    defer { isSyncing = false }
    do {
      let changes = try await connection.sync.synchronize()
      try apply(changes, context: context)
      if announcing { message = "Cloudflare sync complete." }
    } catch {
      if announcing { message = "Cloudflare sync will retry when you are online." }
    }
  }

  func enqueue(_ record: TradeRecord) {
    guard let connection, let completedAt = record.completedAt else { return }
    let recordId = record.id.uuidString.lowercased()
    let occurredAt = Self.iso(completedAt)
    let payload = HabitsPlatformRecord.encode(record)
    Task {
      do {
        try await connection.sync.enqueue(
          recordId: recordId,
          occurredAt: occurredAt,
          record: payload
        )
        _ = try? await connection.sync.synchronize()
      } catch {}
    }
  }

  private func apply(_ changes: [SyncChange], context: ModelContext) throws {
    let existing = try context.fetch(FetchDescriptor<TradeRecord>())
    for change in changes {
      let id = HabitsPlatformRecord.stableUUID(change.id)
      if change.operation == .delete {
        if let record = existing.first(where: { $0.id == id }) { context.delete(record) }
        continue
      }
      guard !existing.contains(where: { $0.id == id }),
        let record = HabitsPlatformRecord.decode(change)
      else { continue }
      context.insert(record)
    }
    if context.hasChanges { try context.save() }
  }

  private static func iso(_ date: Date) -> String {
    ISO8601DateFormatter().string(from: date)
  }
}

enum HabitsPlatformRecord {
  static func encode(_ record: TradeRecord) -> JSONValue {
    let outcome = record.outcome?.rawValue ?? TradeOutcome.anotherDay.rawValue
    let habitId = [
      "trade",
      record.indulgenceRawValue,
      record.destinationRawValue,
      String(record.reclaimMinutes),
      outcome,
    ].joined(separator: "|")
    return .object([
      "habitId": .string(habitId),
      "name": .string("\(record.indulgence.title) → \(record.destination.title)"),
      "occurredOn": .string(
        ISO8601DateFormatter().string(from: record.completedAt ?? record.updatedAt)),
      "status": .string(record.outcome == .madeRoom ? "completed" : "skipped"),
    ])
  }

  static func decode(_ change: SyncChange) -> TradeRecord? {
    guard case .object(let record) = change.record,
      case .string(let habitId)? = record["habitId"],
      case .string(let occurredOn)? = record["occurredOn"],
      let occurredAt = ISO8601DateFormatter().date(from: occurredOn)
    else { return nil }
    let parts = habitId.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
    let indulgence = parts.count > 1 ? IndulgenceChoice(rawValue: parts[1]) : nil
    let destination = parts.count > 2 ? LifeDirection(rawValue: parts[2]) : nil
    let minutes = parts.count > 3 ? Int(parts[3]) : nil
    let outcome = parts.count > 4 ? TradeOutcome(rawValue: parts[4]) : nil
    return TradeRecord(
      id: stableUUID(change.id),
      indulgence: indulgence ?? .television,
      reclaimTarget: ReclaimTarget(rawValue: minutes ?? 15) ?? .fifteen,
      destination: destination ?? .presence,
      createdAt: occurredAt,
      startedAt: occurredAt,
      completedAt: occurredAt,
      outcome: outcome ?? statusOutcome(record["status"])
    )
  }

  static func stableUUID(_ value: String) -> UUID {
    if let uuid = UUID(uuidString: value) { return uuid }
    let bytes = Array(SHA256.hash(data: Data(value.utf8)).prefix(16))
    return UUID(
      uuid: (
        bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
        bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
      ))
  }

  private static func statusOutcome(_ value: JSONValue?) -> TradeOutcome {
    guard case .string(let status)? = value else { return .madeRoom }
    return status == "completed" ? .madeRoom : .anotherDay
  }
}
