import Foundation
import ImageIO
import SwiftData

enum FutureLifeCardStoreError: Error, Equatable {
  case invalidImage
  case invalidOwnedFileName
}

enum FutureLifeCardCreationState: Equatable, Sendable {
  case idle
  case presenting
  case cancelled
  case retained
}

enum FutureLifeCardAvailability {
  static func isActionVisible(
    supportsSystemSheet: Bool,
    lifeDirections: Set<LifeDirection>
  ) -> Bool {
    supportsSystemSheet && !lifeDirections.isEmpty
  }
}

struct FutureLifeCardConcepts {
  static func texts(for profile: OnboardingProfile) -> [String] {
    profile.lifeDirections
      .sorted { $0.rawValue < $1.rawValue }
      .prefix(3)
      .map { "A gentle future with \($0.title.lowercased())" }
  }
}

struct FutureLifeCardAssetStore {
  let rootURL: URL
  private let fileManager: FileManager

  init(
    rootURL: URL? = nil,
    fileManager: FileManager = .default
  ) throws {
    self.fileManager = fileManager
    if let rootURL {
      self.rootURL = rootURL.standardizedFileURL
    } else {
      let support = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      self.rootURL =
        support
        .appendingPathComponent("Indulge", isDirectory: true)
        .appendingPathComponent("FutureLifeCards", isDirectory: true)
        .standardizedFileURL
    }
  }

  func retainImage(from sourceURL: URL, id: UUID = UUID()) throws -> String {
    guard
      let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      CGImageSourceGetCount(source) > 0
    else { throw FutureLifeCardStoreError.invalidImage }

    try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
    let sourceExtension = sourceURL.pathExtension.lowercased()
    let safeExtension =
      sourceExtension.range(of: "^[a-z0-9]{1,5}$", options: .regularExpression) == nil
      ? "image" : sourceExtension
    let fileName = "future-life-card-\(id.uuidString.lowercased()).\(safeExtension)"
    let destination = try ownedURL(for: fileName)
    let temporary = rootURL.appendingPathComponent(".\(fileName).incoming")

    if fileManager.fileExists(atPath: temporary.path) { try fileManager.removeItem(at: temporary) }
    try fileManager.copyItem(at: sourceURL, to: temporary)
    do {
      try fileManager.moveItem(at: temporary, to: destination)
    } catch {
      if fileManager.fileExists(atPath: temporary.path) {
        try? fileManager.removeItem(at: temporary)
      }
      throw error
    }
    return fileName
  }

  func url(for fileName: String) throws -> URL {
    try ownedURL(for: fileName)
  }

  func delete(fileName: String) throws {
    let url = try ownedURL(for: fileName)
    if fileManager.fileExists(atPath: url.path) { try fileManager.removeItem(at: url) }
  }

  func deleteUnreferencedFiles(retaining retainedFileNames: Set<String>) throws {
    guard fileManager.fileExists(atPath: rootURL.path) else { return }
    let urls = try fileManager.contentsOfDirectory(
      at: rootURL,
      includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey],
      options: [.skipsHiddenFiles]
    )
    for url in urls {
      let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
      let fileName = url.lastPathComponent
      guard
        values.isRegularFile == true,
        values.isSymbolicLink != true,
        fileName.hasPrefix("future-life-card-"),
        !retainedFileNames.contains(fileName)
      else { continue }
      try fileManager.removeItem(at: try ownedURL(for: fileName))
    }
  }

  private func ownedURL(for fileName: String) throws -> URL {
    let ownedNamePattern =
      #"^future-life-card-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[a-z0-9]{1,5}$"#
    guard
      fileName.range(of: ownedNamePattern, options: .regularExpression) != nil,
      fileName == URL(fileURLWithPath: fileName).lastPathComponent
    else {
      throw FutureLifeCardStoreError.invalidOwnedFileName
    }
    return rootURL.appendingPathComponent(fileName, isDirectory: false)
  }
}

@MainActor
struct FutureLifeCardRepository {
  let context: ModelContext
  let assets: FutureLifeCardAssetStore

  func retain(
    imageAt sourceURL: URL,
    lifeDirections: Set<LifeDirection>,
    at date: Date = .now
  ) throws -> FutureLifeCardRecord {
    let previous = try context.fetch(FetchDescriptor<FutureLifeCardRecord>())
    let fileName = try assets.retainImage(from: sourceURL)
    let record = try FutureLifeCardRecord(
      imageFileName: fileName,
      lifeDirections: lifeDirections,
      createdAt: date
    )
    for oldRecord in previous { context.delete(oldRecord) }
    context.insert(record)

    do {
      try context.save()
    } catch {
      try? assets.delete(fileName: fileName)
      context.rollback()
      throw error
    }
    try? assets.deleteUnreferencedFiles(retaining: [record.imageFileName])
    return record
  }

  func delete(_ record: FutureLifeCardRecord) throws {
    context.delete(record)
    do {
      try context.save()
    } catch {
      context.rollback()
      throw error
    }
    let retainedFileNames = Set(
      try context.fetch(FetchDescriptor<FutureLifeCardRecord>()).map(\.imageFileName)
    )
    try assets.deleteUnreferencedFiles(retaining: retainedFileNames)
  }
}
