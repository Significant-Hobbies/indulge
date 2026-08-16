import Foundation
import SwiftData
import Testing

@testable import Indulge

@MainActor
struct TradeJournalTests {
  @Test func activeTradePersistsAcrossContainerRecreation() throws {
    let fixture = try StoreFixture()
    defer { fixture.remove() }
    let id: UUID

    do {
      let container = try IndulgeModelContainer.make(storeURL: fixture.storeURL)
      let record = try TradeRepository(context: container.mainContext).create(
        indulgence: .consoleGaming,
        reclaimTarget: .thirty,
        destination: .creativity,
        at: Date(timeIntervalSince1970: 100)
      )
      try TradeRepository(context: container.mainContext).begin(
        record,
        at: Date(timeIntervalSince1970: 110)
      )
      id = record.id
    }

    let reopened = try IndulgeModelContainer.make(storeURL: fixture.storeURL)
    let active = try #require(try TradeRepository(context: reopened.mainContext).active())
    #expect(active.id == id)
    #expect(active.indulgence == .consoleGaming)
    #expect(active.reclaimTarget == .thirty)
    #expect(active.destination == .creativity)
    #expect(active.startedAt == Date(timeIntervalSince1970: 110))
  }

  @Test func secondActiveTradeRequiresExplicitReplacement() throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    let repository = TradeRepository(context: container.mainContext)
    let first = try repository.create(
      indulgence: .television,
      reclaimTarget: .fifteen,
      destination: .presence,
      at: Date(timeIntervalSince1970: 100)
    )

    #expect(throws: TradeRepositoryError.activeTradeExists) {
      try repository.create(
        indulgence: .webBrowsing,
        reclaimTarget: .thirty,
        destination: .focus,
        at: Date(timeIntervalSince1970: 200)
      )
    }
    #expect(try repository.active()?.id == first.id)

    let replacement = try repository.create(
      indulgence: .webBrowsing,
      reclaimTarget: .thirty,
      destination: .focus,
      replacingActive: true,
      at: Date(timeIntervalSince1970: 200)
    )
    #expect(first.supersededAt == Date(timeIntervalSince1970: 200))
    #expect(try repository.active()?.id == replacement.id)
    #expect(try repository.completed().isEmpty)
  }

  @Test(arguments: TradeOutcome.allCases)
  func eachCompletionOutcomeBecomesTruthfulHistory(outcome: TradeOutcome) throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    let repository = TradeRepository(context: container.mainContext)
    let record = try repository.create(
      indulgence: .shortVideo,
      reclaimTarget: .fifteen,
      destination: .calm,
      at: Date(timeIntervalSince1970: 100)
    )

    try repository.complete(record, outcome: outcome, at: Date(timeIntervalSince1970: 160))

    #expect(try repository.active() == nil)
    let completed = try #require(repository.completed().first)
    #expect(completed.id == record.id)
    #expect(completed.outcome == outcome)
    #expect(completed.startedAt == Date(timeIntervalSince1970: 160))
    #expect(completed.completedAt == Date(timeIntervalSince1970: 160))
  }

  @Test func historyIsNewestFirstAndExcludesSupersededDrafts() throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    let repository = TradeRepository(context: container.mainContext)
    let older = try repository.create(
      indulgence: .music,
      reclaimTarget: .fifteen,
      destination: .presence,
      at: Date(timeIntervalSince1970: 100)
    )
    try repository.complete(older, outcome: .madeRoom, at: Date(timeIntervalSince1970: 200))
    let newer = try repository.create(
      indulgence: .consoleGaming,
      reclaimTarget: .thirty,
      destination: .movement,
      at: Date(timeIntervalSince1970: 300)
    )
    try repository.complete(newer, outcome: .choseIndulgence, at: Date(timeIntervalSince1970: 400))
    _ = try repository.create(
      indulgence: .television,
      reclaimTarget: .fifteen,
      destination: .calm,
      at: Date(timeIntervalSince1970: 500)
    )
    _ = try repository.create(
      indulgence: .podcasts,
      reclaimTarget: .fifteen,
      destination: .focus,
      replacingActive: true,
      at: Date(timeIntervalSince1970: 600)
    )

    #expect(try repository.completed().map(\.id) == [newer.id, older.id])
  }

  @Test func startupRepairKeepsNewestActiveRecord() throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    let context = container.mainContext
    let older = TradeRecord(
      indulgence: .television,
      reclaimTarget: .fifteen,
      destination: .presence,
      createdAt: Date(timeIntervalSince1970: 100)
    )
    let newer = TradeRecord(
      indulgence: .webBrowsing,
      reclaimTarget: .thirty,
      destination: .focus,
      createdAt: Date(timeIntervalSince1970: 200)
    )
    context.insert(older)
    context.insert(newer)
    try context.save()

    let active = try #require(try TradeRepository(context: context).active())

    #expect(active.id == newer.id)
    #expect(older.supersededAt == newer.updatedAt)
  }

  private struct StoreFixture {
    let directory: URL
    let storeURL: URL

    init() throws {
      directory = FileManager.default.temporaryDirectory.appending(
        path: "indulge-trades-\(UUID().uuidString)",
        directoryHint: .isDirectory
      )
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      storeURL = directory.appending(path: "indulge.store")
    }

    func remove() {
      try? FileManager.default.removeItem(at: directory)
    }
  }
}
