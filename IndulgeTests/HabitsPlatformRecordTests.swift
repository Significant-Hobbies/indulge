import Foundation
import PersonalSyncKit
import XCTest

@testable import Indulge

final class HabitsPlatformRecordTests: XCTestCase {
  func testCompletedTradeUsesTheHabitsContract() throws {
    let completedAt = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-08-21T08:30:00Z"))
    let record = TradeRecord(
      indulgence: .socialFeeds,
      reclaimTarget: .thirty,
      destination: .movement,
      createdAt: completedAt.addingTimeInterval(-1_800),
      startedAt: completedAt.addingTimeInterval(-1_800),
      completedAt: completedAt,
      outcome: .madeRoom
    )

    guard case .object(let payload) = HabitsPlatformRecord.encode(record) else {
      return XCTFail("Expected an object record")
    }
    XCTAssertEqual(
      payload["habitId"],
      .string("trade|socialFeeds|movement|30|madeRoom")
    )
    XCTAssertEqual(payload["occurredOn"], .string("2026-08-21T08:30:00Z"))
    XCTAssertEqual(payload["status"], .string("completed"))
  }

  func testPlatformRecordRecreatesTheTradeAndStableIdentity() throws {
    let change = try decodeChange(
      id: "pace-trade",
      record: """
        {"habitId":"trade|shortVideo|creativity|45|anotherDay","name":"A trade","occurredOn":"2026-08-21T09:00:00Z","status":"skipped"}
        """
    )

    let first = try XCTUnwrap(HabitsPlatformRecord.decode(change))
    let second = try XCTUnwrap(HabitsPlatformRecord.decode(change))
    XCTAssertEqual(first.id, second.id)
    XCTAssertEqual(first.indulgence, .shortVideo)
    XCTAssertEqual(first.destination, .creativity)
    XCTAssertEqual(first.reclaimTarget, .fortyFive)
    XCTAssertEqual(first.outcome, .anotherDay)
  }

  func testGenericCheckInFallsBackToAUsefulHistoryRecord() throws {
    let change = try decodeChange(
      id: "generic-check-in",
      record: """
        {"habitId":"walk","name":"Walk","occurredOn":"2026-08-21T10:00:00Z","status":"completed"}
        """
    )
    let record = try XCTUnwrap(HabitsPlatformRecord.decode(change))
    XCTAssertEqual(record.indulgence, .television)
    XCTAssertEqual(record.destination, .presence)
    XCTAssertEqual(record.outcome, .madeRoom)
  }

  private func decodeChange(id: String, record: String) throws -> SyncChange {
    let payload = """
      {"cursor":1,"changeId":"change-1","domain":"habits","id":"\(id)","operation":"upsert","version":1,"occurredAt":"2026-08-21T10:00:00Z","recordedAt":"2026-08-21T10:00:01Z","originDeviceId":"pace","record":\(record)}
      """
    return try JSONDecoder().decode(SyncChange.self, from: Data(payload.utf8))
  }
}
