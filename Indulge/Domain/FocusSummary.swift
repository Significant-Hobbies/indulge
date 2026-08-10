import Foundation

struct FocusDaySummary: Equatable, Sendable, Identifiable {
  let day: Date
  let focusedDuration: TimeInterval
  let interruptionCount: Int
  let recoveryDuration: TimeInterval
  let sourceCounts: [FocusInterruptionSource: Int]

  var id: Date { day }
}

enum FocusAggregateInsight: Equatable, Sendable {
  case learning(remaining: Int)
  case pattern(
    source: FocusInterruptionSource,
    reason: FocusInterruptionReason,
    blockage: FocusReturnBlockage,
    averageRecovery: TimeInterval,
    observationCount: Int
  )
}

enum FocusSummary {
  static let minimumPatternObservations = 3

  static func days(
    sessions: [FocusSessionSnapshot],
    interruptions: [FocusInterruptionSnapshot],
    now: Date = .now,
    calendar: Calendar = .autoupdatingCurrent
  ) -> [FocusDaySummary] {
    guard !sessions.isEmpty || !interruptions.isEmpty else { return [] }

    var sessionDurationByDay: [Date: TimeInterval] = [:]
    var recoveryDurationByDay: [Date: TimeInterval] = [:]
    var interruptionCountByDay: [Date: Int] = [:]
    var sourceCountsByDay: [Date: [FocusInterruptionSource: Int]] = [:]

    for session in sessions {
      accumulate(
        start: session.startedAt,
        end: session.endedAt ?? now,
        calendar: calendar,
        into: &sessionDurationByDay
      )
    }

    for interruption in interruptions {
      let interruptionDay = calendar.startOfDay(for: interruption.interruptedAt)
      interruptionCountByDay[interruptionDay, default: 0] += 1
      if let source = interruption.source {
        sourceCountsByDay[interruptionDay, default: [:]][source, default: 0] += 1
      }
      accumulate(
        start: interruption.interruptedAt,
        end: interruption.returnedAt ?? now,
        calendar: calendar,
        into: &recoveryDurationByDay
      )
    }

    let visibleDays = Set(sessionDurationByDay.keys).union(interruptionCountByDay.keys)
    return visibleDays.sorted(by: >).map { day in
      let sessionDuration = sessionDurationByDay[day, default: 0]
      let recoveryDuration = recoveryDurationByDay[day, default: 0]
      return FocusDaySummary(
        day: day,
        focusedDuration: max(0, sessionDuration - recoveryDuration),
        interruptionCount: interruptionCountByDay[day, default: 0],
        recoveryDuration: recoveryDuration,
        sourceCounts: sourceCountsByDay[day, default: [:]]
      )
    }
  }

  static func aggregate(
    interruptions: [FocusInterruptionSnapshot]
  ) -> FocusAggregateInsight {
    let completed = interruptions.filter {
      $0.returnedAt != nil && $0.source != nil && $0.reason != nil && $0.blockage != nil
    }
    guard completed.count >= minimumPatternObservations else {
      return .learning(remaining: minimumPatternObservations - completed.count)
    }

    let source =
      mostFrequent(
        completed.compactMap(\.source),
        authoredOrder: FocusInterruptionSource.allCases
      ) ?? .drift
    let reason =
      mostFrequent(
        completed.compactMap(\.reason),
        authoredOrder: FocusInterruptionReason.allCases
      ) ?? .other
    let blockage =
      mostFrequent(
        completed.compactMap(\.blockage),
        authoredOrder: FocusReturnBlockage.allCases
      ) ?? .notSure
    let recovery = completed.reduce(0) { partial, event in
      partial
        + max(0, (event.returnedAt ?? event.interruptedAt).timeIntervalSince(event.interruptedAt))
    }

    return .pattern(
      source: source,
      reason: reason,
      blockage: blockage,
      averageRecovery: recovery / Double(completed.count),
      observationCount: completed.count
    )
  }

  private static func overlap(
    start: Date,
    end: Date,
    with range: Range<Date>
  ) -> TimeInterval {
    let clippedStart = max(start, range.lowerBound)
    let clippedEnd = min(max(end, start), range.upperBound)
    return max(0, clippedEnd.timeIntervalSince(clippedStart))
  }

  private static func accumulate(
    start: Date,
    end: Date,
    calendar: Calendar,
    into durations: inout [Date: TimeInterval]
  ) {
    let resolvedEnd = max(end, start)
    var cursor = calendar.startOfDay(for: start)

    while cursor <= resolvedEnd {
      guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
      let duration = overlap(start: start, end: resolvedEnd, with: cursor..<nextDay)
      if duration > 0 {
        durations[cursor, default: 0] += duration
      }
      if nextDay >= resolvedEnd { break }
      cursor = nextDay
    }
  }

  private static func mostFrequent<Value: Hashable>(
    _ values: [Value],
    authoredOrder: [Value]
  ) -> Value? {
    let counts = Dictionary(grouping: values, by: { $0 }).mapValues(\.count)
    return authoredOrder.max { lhs, rhs in
      (counts[lhs, default: 0], -authoredOrder.firstIndex(of: lhs, default: 0))
        < (counts[rhs, default: 0], -authoredOrder.firstIndex(of: rhs, default: 0))
    }
  }
}

extension Array where Element: Equatable {
  fileprivate func firstIndex(of element: Element, default fallback: Int) -> Int {
    firstIndex(of: element) ?? fallback
  }
}
