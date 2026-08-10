import Foundation
import SwiftData

@Model
final class OnboardingProfileRecord {
  #Index<OnboardingProfileRecord>([\.id], [\.updatedAt])

  var id: UUID = UUID()
  var encodedProfile: Data = Data()
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now

  init(
    id: UUID = UUID(),
    profile: OnboardingProfile,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) throws {
    self.id = id
    encodedProfile = try JSONEncoder().encode(profile)
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  var profile: OnboardingProfile? {
    try? JSONDecoder().decode(OnboardingProfile.self, from: encodedProfile)
  }

  func update(profile: OnboardingProfile, at date: Date = .now) throws {
    encodedProfile = try JSONEncoder().encode(profile)
    updatedAt = date
  }
}

@Model
final class GeneratedReflectionRecord {
  #Index<GeneratedReflectionRecord>([\.id], [\.evidenceRevision])

  var id: UUID = UUID()
  var evidenceRevision: String = ""
  var headline: String = ""
  var observation: String = ""
  var question: String?
  var createdAt: Date = Date.now

  init(
    id: UUID = UUID(),
    evidenceRevision: String,
    headline: String,
    observation: String,
    question: String? = nil,
    createdAt: Date = .now
  ) {
    self.id = id
    self.evidenceRevision = evidenceRevision
    self.headline = headline
    self.observation = observation
    self.question = question
    self.createdAt = createdAt
  }
}

@Model
final class FutureLifeCardRecord {
  #Index<FutureLifeCardRecord>([\.id], [\.createdAt])

  var id: UUID = UUID()
  var imageFileName: String = ""
  var encodedLifeDirections: Data = Data()
  var createdAt: Date = Date.now

  init(
    id: UUID = UUID(),
    imageFileName: String,
    lifeDirections: Set<LifeDirection>,
    createdAt: Date = .now
  ) throws {
    self.id = id
    self.imageFileName = imageFileName
    encodedLifeDirections = try JSONEncoder().encode(lifeDirections)
    self.createdAt = createdAt
  }

  var lifeDirections: Set<LifeDirection> {
    (try? JSONDecoder().decode(Set<LifeDirection>.self, from: encodedLifeDirections)) ?? []
  }
}

enum IndulgeDataSchemaV1: VersionedSchema {
  static let versionIdentifier = Schema.Version(1, 0, 0)
  static var models: [any PersistentModel.Type] {
    [
      FocusSessionRecord.self,
      FocusInterruptionRecord.self,
      OnboardingProfileRecord.self,
      GeneratedReflectionRecord.self,
      FutureLifeCardRecord.self,
    ]
  }
}

enum IndulgeDataMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] { [IndulgeDataSchemaV1.self] }
  static var stages: [MigrationStage] { [] }
}

@MainActor
struct OnboardingProfileRepository {
  let context: ModelContext

  func latest() throws -> OnboardingProfile? {
    var descriptor = FetchDescriptor<OnboardingProfileRecord>(
      sortBy: [SortDescriptor(\OnboardingProfileRecord.updatedAt, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    return try context.fetch(descriptor).first?.profile
  }

  func save(_ profile: OnboardingProfile, at date: Date = .now) throws {
    let records = try context.fetch(FetchDescriptor<OnboardingProfileRecord>())
    if let retained = records.max(by: { $0.updatedAt < $1.updatedAt }) {
      try retained.update(profile: profile, at: date)
      for duplicate in records where duplicate !== retained { context.delete(duplicate) }
    } else {
      context.insert(
        try OnboardingProfileRecord(profile: profile, createdAt: date, updatedAt: date))
    }
    try context.save()
  }

  func delete() throws {
    for record in try context.fetch(FetchDescriptor<OnboardingProfileRecord>()) {
      context.delete(record)
    }
    try context.save()
  }
}

@MainActor
struct GeneratedStateRepository {
  let context: ModelContext

  func reflection(for evidenceRevision: String) throws -> PersonalReflection? {
    let revision = evidenceRevision
    var descriptor = FetchDescriptor<GeneratedReflectionRecord>(
      predicate: #Predicate { $0.evidenceRevision == revision },
      sortBy: [SortDescriptor(\GeneratedReflectionRecord.createdAt, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    guard let record = try context.fetch(descriptor).first else { return nil }
    return PersonalReflection(
      evidenceRevision: record.evidenceRevision,
      headline: record.headline,
      observation: record.observation,
      question: record.question
    )
  }

  func saveReflection(_ reflection: PersonalReflection, at date: Date = .now) throws {
    let records = try context.fetch(FetchDescriptor<GeneratedReflectionRecord>())
    for record in records { context.delete(record) }
    context.insert(
      GeneratedReflectionRecord(
        evidenceRevision: reflection.evidenceRevision,
        headline: reflection.headline,
        observation: reflection.observation,
        question: reflection.question,
        createdAt: date
      )
    )
    try context.save()
  }

  func invalidateReflections(except evidenceRevision: String) throws {
    let records = try context.fetch(FetchDescriptor<GeneratedReflectionRecord>())
    var changed = false
    for record in records where record.evidenceRevision != evidenceRevision {
      context.delete(record)
      changed = true
    }
    if changed { try context.save() }
  }

  func deleteReflection(_ record: GeneratedReflectionRecord) throws {
    context.delete(record)
    try context.save()
  }

  func deleteCard(_ record: FutureLifeCardRecord) throws {
    context.delete(record)
    try context.save()
  }
}

@MainActor
struct AllIndulgeDataRepository {
  let context: ModelContext
  let cardAssets: FutureLifeCardAssetStore

  func deleteAll() throws {
    let cards = try context.fetch(FetchDescriptor<FutureLifeCardRecord>())

    for record in try context.fetch(FetchDescriptor<FocusInterruptionRecord>()) {
      context.delete(record)
    }
    for record in try context.fetch(FetchDescriptor<FocusSessionRecord>()) {
      context.delete(record)
    }
    for record in try context.fetch(FetchDescriptor<OnboardingProfileRecord>()) {
      context.delete(record)
    }
    for record in try context.fetch(FetchDescriptor<GeneratedReflectionRecord>()) {
      context.delete(record)
    }
    for record in cards { context.delete(record) }
    do {
      try context.save()
    } catch {
      context.rollback()
      throw error
    }
    try cardAssets.deleteUnreferencedFiles(retaining: [])
  }
}
