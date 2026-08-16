import Foundation
import SwiftData

enum ReclaimTarget: Int, CaseIterable, Codable, Equatable, Sendable {
  case fifteen = 15
  case thirty = 30
  case fortyFive = 45

  var title: String { "\(rawValue) min" }

  static func suggested(for time: DailyTime?) -> Self {
    switch time {
    case .underThirty, .none: .fifteen
    case .aboutOneHour: .fifteen
    case .twoHours: .thirty
    case .threePlus: .fortyFive
    }
  }
}

enum TradeOutcome: String, CaseIterable, Codable, Equatable, Sendable {
  case madeRoom
  case choseIndulgence
  case anotherDay

  var title: String {
    switch self {
    case .madeRoom: "I made some room"
    case .choseIndulgence: "I chose to keep enjoying it"
    case .anotherDay: "Another day"
    }
  }

  var historyTitle: String {
    switch self {
    case .madeRoom: "Made room"
    case .choseIndulgence: "Chose the pleasure"
    case .anotherDay: "Left it for another day"
    }
  }

  var systemImage: String {
    switch self {
    case .madeRoom: "sparkles"
    case .choseIndulgence: "heart.fill"
    case .anotherDay: "arrow.uturn.backward"
    }
  }
}

struct ActiveTrade: Equatable, Sendable {
  let id: UUID
  let indulgence: IndulgenceChoice
  let reclaimTarget: ReclaimTarget
  let destination: LifeDirection
  let createdAt: Date
  let startedAt: Date?

  var hasStarted: Bool { startedAt != nil }
}

@Model
final class TradeRecord {
  #Index<TradeRecord>([\.id], [\.updatedAt], [\.completedAt])

  var id: UUID = UUID()
  var indulgenceRawValue: String = IndulgenceChoice.television.rawValue
  var reclaimMinutes: Int = ReclaimTarget.fifteen.rawValue
  var destinationRawValue: String = LifeDirection.presence.rawValue
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now
  var startedAt: Date?
  var completedAt: Date?
  var outcomeRawValue: String?
  var supersededAt: Date?

  init(
    id: UUID = UUID(),
    indulgence: IndulgenceChoice,
    reclaimTarget: ReclaimTarget,
    destination: LifeDirection,
    createdAt: Date = .now,
    startedAt: Date? = nil,
    completedAt: Date? = nil,
    outcome: TradeOutcome? = nil,
    supersededAt: Date? = nil
  ) {
    self.id = id
    indulgenceRawValue = indulgence.rawValue
    reclaimMinutes = reclaimTarget.rawValue
    destinationRawValue = destination.rawValue
    self.createdAt = createdAt
    updatedAt = completedAt ?? startedAt ?? createdAt
    self.startedAt = startedAt
    self.completedAt = completedAt
    outcomeRawValue = outcome?.rawValue
    self.supersededAt = supersededAt
  }

  var indulgence: IndulgenceChoice {
    IndulgenceChoice(rawValue: indulgenceRawValue) ?? .television
  }

  var reclaimTarget: ReclaimTarget {
    ReclaimTarget(rawValue: reclaimMinutes) ?? .fifteen
  }

  var destination: LifeDirection {
    LifeDirection(rawValue: destinationRawValue) ?? .presence
  }

  var outcome: TradeOutcome? {
    get { outcomeRawValue.flatMap(TradeOutcome.init(rawValue:)) }
    set { outcomeRawValue = newValue?.rawValue }
  }

  var isActive: Bool {
    completedAt == nil && supersededAt == nil
  }

  var activeValue: ActiveTrade? {
    guard isActive else { return nil }
    return ActiveTrade(
      id: id,
      indulgence: indulgence,
      reclaimTarget: reclaimTarget,
      destination: destination,
      createdAt: createdAt,
      startedAt: startedAt
    )
  }
}

enum TradeRepositoryError: Error, Equatable {
  case activeTradeExists
  case recordIsNotActive
}

@MainActor
struct TradeRepository {
  let context: ModelContext

  func active() throws -> TradeRecord? {
    let records = try activeRecords()
    guard let retained = records.first else { return nil }

    if records.count > 1 {
      for duplicate in records.dropFirst() {
        duplicate.supersededAt = retained.updatedAt
        duplicate.updatedAt = retained.updatedAt
      }
      do {
        try context.save()
      } catch {
        context.rollback()
        throw error
      }
    }
    return retained
  }

  @discardableResult
  func create(
    indulgence: IndulgenceChoice,
    reclaimTarget: ReclaimTarget,
    destination: LifeDirection,
    replacingActive: Bool = false,
    at date: Date = .now
  ) throws -> TradeRecord {
    if let current = try active() {
      guard replacingActive else { throw TradeRepositoryError.activeTradeExists }
      current.supersededAt = date
      current.updatedAt = date
    }

    let record = TradeRecord(
      indulgence: indulgence,
      reclaimTarget: reclaimTarget,
      destination: destination,
      createdAt: date
    )
    context.insert(record)
    do {
      try context.save()
    } catch {
      context.rollback()
      throw error
    }
    return record
  }

  func begin(_ record: TradeRecord, at date: Date = .now) throws {
    guard record.isActive else { throw TradeRepositoryError.recordIsNotActive }
    if record.startedAt == nil { record.startedAt = date }
    record.updatedAt = date
    do {
      try context.save()
    } catch {
      context.rollback()
      throw error
    }
  }

  func complete(_ record: TradeRecord, outcome: TradeOutcome, at date: Date = .now) throws {
    guard record.isActive else { throw TradeRepositoryError.recordIsNotActive }
    if record.startedAt == nil { record.startedAt = date }
    record.outcome = outcome
    record.completedAt = date
    record.updatedAt = date
    do {
      try context.save()
    } catch {
      context.rollback()
      throw error
    }
  }

  func completed() throws -> [TradeRecord] {
    try context.fetch(
      FetchDescriptor<TradeRecord>(
        predicate: #Predicate { $0.completedAt != nil },
        sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
      ))
  }

  private func activeRecords() throws -> [TradeRecord] {
    try context.fetch(
      FetchDescriptor<TradeRecord>(
        predicate: #Predicate { $0.completedAt == nil && $0.supersededAt == nil },
        sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
      ))
  }
}
