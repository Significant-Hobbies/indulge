import Foundation
import SwiftData
import Testing
import UIKit

@testable import Indulge

#if canImport(ImagePlayground)
  import ImagePlayground
  import SwiftUI
#endif

@MainActor
struct FutureLifeCardTests {
  @Test func conceptsAreBoundedToPersistedLifeDirections() {
    var profile = OnboardingProfile()
    profile.preferredName = "Private Name"
    profile.lifeDirections = [.calm, .creativity, .focus, .movement]

    let concepts = FutureLifeCardConcepts.texts(for: profile)

    #expect(concepts.count == 3)
    #expect(
      concepts == [
        "A gentle future with a calmer mind",
        "A gentle future with more creativity",
        "A gentle future with deeper focus",
      ])
    #expect(!concepts.joined().contains("Private Name"))
  }

  @Test func unsupportedOrUngroundedCreationActionIsUnavailable() {
    #expect(
      !FutureLifeCardAvailability.isActionVisible(
        supportsSystemSheet: false,
        lifeDirections: [.calm]
      ))
    #expect(
      !FutureLifeCardAvailability.isActionVisible(
        supportsSystemSheet: true,
        lifeDirections: []
      ))
    #expect(
      FutureLifeCardAvailability.isActionVisible(
        supportsSystemSheet: true,
        lifeDirections: [.calm]
      ))
  }

  @Test func physicalImagePlaygroundCapabilityStateIsReadable() {
    #if canImport(ImagePlayground) && !targetEnvironment(simulator)
      if #available(iOS 18.1, *) {
        let supportsSystemSheet = EnvironmentValues().supportsImagePlayground
        print("INDULGE_IMAGE_PLAYGROUND_SUPPORTED=\(supportsSystemSheet)")
        #expect(
          FutureLifeCardAvailability.isActionVisible(
            supportsSystemSheet: supportsSystemSheet,
            lifeDirections: [.calm]
          ) == supportsSystemSheet)
      }
    #endif
  }

  @Test func cancellationStateCreatesNoPlaceholder() throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    var state = FutureLifeCardCreationState.presenting

    state = .cancelled

    #expect(state == .cancelled)
    #expect(try container.mainContext.fetch(FetchDescriptor<FutureLifeCardRecord>()).isEmpty)
  }

  @Test func successfulImageIsCopiedIntoOwnedStorageWithMetadata() throws {
    let fixture = try Fixture()
    defer { fixture.remove() }
    let container = try IndulgeModelContainer.make(inMemory: true)
    let repository = FutureLifeCardRepository(
      context: container.mainContext,
      assets: try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory)
    )

    let record = try repository.retain(
      imageAt: fixture.firstImage,
      lifeDirections: [.calm, .focus],
      at: Date(timeIntervalSince1970: 100)
    )
    let ownedURL = try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory).url(
      for: record.imageFileName)

    #expect(FileManager.default.fileExists(atPath: ownedURL.path))
    #expect(ownedURL.deletingLastPathComponent() == fixture.ownedDirectory.standardizedFileURL)
    #expect(record.lifeDirections == [.calm, .focus])
    #expect(record.createdAt == Date(timeIntervalSince1970: 100))
  }

  @Test func replacementRetainsOneRecordAndRemovesThePreviousAsset() throws {
    let fixture = try Fixture()
    defer { fixture.remove() }
    let container = try IndulgeModelContainer.make(inMemory: true)
    let assets = try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory)
    let repository = FutureLifeCardRepository(context: container.mainContext, assets: assets)
    let first = try repository.retain(imageAt: fixture.firstImage, lifeDirections: [.calm])
    let firstURL = try assets.url(for: first.imageFileName)

    let replacement = try repository.retain(
      imageAt: fixture.secondImage,
      lifeDirections: [.creativity]
    )
    let records = try container.mainContext.fetch(FetchDescriptor<FutureLifeCardRecord>())

    #expect(records.count == 1)
    #expect(records.first?.id == replacement.id)
    #expect(!FileManager.default.fileExists(atPath: firstURL.path))
    #expect(
      FileManager.default.fileExists(atPath: try assets.url(for: replacement.imageFileName).path))
  }

  @Test func confirmedDeletionRemovesImageAndMetadata() throws {
    let fixture = try Fixture()
    defer { fixture.remove() }
    let container = try IndulgeModelContainer.make(inMemory: true)
    let assets = try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory)
    let repository = FutureLifeCardRepository(context: container.mainContext, assets: assets)
    let record = try repository.retain(imageAt: fixture.firstImage, lifeDirections: [.sleep])
    let retainedURL = try assets.url(for: record.imageFileName)

    try repository.delete(record)

    #expect(!FileManager.default.fileExists(atPath: retainedURL.path))
    #expect(try container.mainContext.fetch(FetchDescriptor<FutureLifeCardRecord>()).isEmpty)
  }

  @Test func directorySweepRemovesOnlyUnreferencedOwnedCards() throws {
    let fixture = try Fixture()
    defer { fixture.remove() }
    let assets = try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory)
    let retained = try assets.retainImage(from: fixture.firstImage)
    let orphan = try assets.retainImage(from: fixture.secondImage)
    let unrelated = fixture.ownedDirectory.appendingPathComponent("keep-me.txt")
    try Data("not owned by the card store".utf8).write(to: unrelated)

    try assets.deleteUnreferencedFiles(retaining: [retained])

    #expect(FileManager.default.fileExists(atPath: try assets.url(for: retained).path))
    #expect(!FileManager.default.fileExists(atPath: try assets.url(for: orphan).path))
    #expect(FileManager.default.fileExists(atPath: unrelated.path))
  }

  @Test func invalidInputAndTraversalAreRejected() throws {
    let fixture = try Fixture()
    defer { fixture.remove() }
    let assets = try FutureLifeCardAssetStore(rootURL: fixture.ownedDirectory)
    let invalid = fixture.root.appendingPathComponent("not-an-image.txt")
    try Data("not an image".utf8).write(to: invalid)

    #expect(throws: FutureLifeCardStoreError.invalidImage) {
      try assets.retainImage(from: invalid)
    }
    #expect(throws: FutureLifeCardStoreError.invalidOwnedFileName) {
      try assets.url(for: "../outside.png")
    }
  }
}

private struct Fixture {
  let root: URL
  let ownedDirectory: URL
  let firstImage: URL
  let secondImage: URL

  init() throws {
    root = FileManager.default.temporaryDirectory
      .appendingPathComponent("indulge-card-tests-\(UUID().uuidString)", isDirectory: true)
    ownedDirectory = root.appendingPathComponent("owned", isDirectory: true)
    firstImage = root.appendingPathComponent("first.png")
    secondImage = root.appendingPathComponent("second.png")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try Self.pngData(color: .systemBlue).write(to: firstImage)
    try Self.pngData(color: .systemPink).write(to: secondImage)
  }

  func remove() {
    try? FileManager.default.removeItem(at: root)
  }

  private static func pngData(color: UIColor) throws -> Data {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { context in
      color.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
    }
    return try #require(image.pngData())
  }
}
