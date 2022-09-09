import Foundation
import stellarsdk

struct PredicateHelper {
  static func parsePredicate(_ predicate: ClaimPredicateXDR) -> [Period] {
    switch predicate {
    case .claimPredicateUnconditional:
      return [Period(start: Date.distantPast, end: Date.distantFuture)]
    case .claimPredicateAnd(let predicatesArray):
      return Period.intersectPeriods(list1: parsePredicate(predicatesArray[0]),
                                     list2: parsePredicate(predicatesArray[1]))
    case .claimPredicateOr(let predicatesArray):
      return Period.unitePeriods(periodList1: parsePredicate(predicatesArray[0]),
                                 periodList2: parsePredicate(predicatesArray[1]))
    case .claimPredicateNot(let predicate):
      if let predicate = predicate {
        return Period.negatePeriods(list: parsePredicate(predicate))
      }
    case .claimPredicateBeforeAbsTime(let value):
      let timeInterval = TimeInterval(value)
      let beforeDate = Date(timeIntervalSince1970: timeInterval)
      return [Period(start: Date.distantPast, end: beforeDate)]
    case .claimPredicateBeforeRelTime(let value):
      let timeInterval = TimeInterval(value)
      let beforeDate = Date(timeIntervalSinceNow: timeInterval)
      return [Period(start: Date.distantPast, end: beforeDate)]
    }
    return []
  }
  
  static func evaluateClaimPredicate(_ predicate: ClaimPredicateXDR,
                                     now: Date) -> ClaimResult
  {
    let periodList = parsePredicate(predicate)

    // Conflict
    if periodList.isEmpty {
      return ClaimResult(canClaimNow: false,
                         expired: false,
                         conflict: true,
                         startPeriod: nil,
                         endPeriod: nil)
    }

    for period in periodList {
      if period.end < now {
        continue
      }

      if period.end == Date.distantFuture {
        if period.start <= now, now <= period.end {
          return ClaimResult(canClaimNow: true,
                             expired: false,
                             conflict: false,
                             startPeriod: nil,
                             endPeriod: nil)
        }
      }

      if period.start <= now, now <= period.end {
        return ClaimResult(canClaimNow: true,
                           expired: false,
                           conflict: false,
                           startPeriod: period.getStartValue(),
                           endPeriod: period.getEndValue())
      }

      if now < period.start {
        return ClaimResult(canClaimNow: false,
                           expired: false,
                           conflict: false,
                           startPeriod: period.getStartValue(),
                           endPeriod: period.getEndValue())
      }
    }

    // Expired.
    return ClaimResult(canClaimNow: false,
                       expired: true,
                       conflict: false,
                       startPeriod: periodList.last?.getStartValue(),
                       endPeriod: periodList.last?.getEndValue())
  }
  
  static func formatBeforeAbsoluteTime(time: String) -> String {
    var beforeAbsoluteTime = time
    if time.hasPrefix("+") {
      beforeAbsoluteTime.remove(at: time.startIndex)
      return beforeAbsoluteTime
    } else {
      return beforeAbsoluteTime
    }
  }
}

struct Period {
  let start: Date
  let end: Date
  
  func getStartValue() -> Date? {
    if start > Date.distantPast {
      return start
    }
    
    return nil
  }
  
  func getEndValue() -> Date? {
    if end < Date.distantFuture {
      return end
    } else if end > Date.distantFuture {
      return end
    } else {
      return nil
    }
  }
}

extension Period {
  static func unitePeriods(periodList1: [Period], periodList2: [Period]) -> [Period] {
    if periodList1.isEmpty, periodList2.isEmpty {
      return []
    }

    var joinedList = periodList1 + periodList2
    joinedList.sort {
      $0.start < $1.start
    }

    var currentPeriod = joinedList[0]
    var resultList: [Period] = []
    // Go through sorted union of periods and look for intersected periods. Unite them into new one.
    for newPeriod in joinedList {
      if currentPeriod.end < newPeriod.start {
        // Periods do not intersect.
        resultList.append(currentPeriod)
        currentPeriod = newPeriod
        continue
      }

      // Unite periods.
      currentPeriod = Period(
        start: min(currentPeriod.start, newPeriod.start),
        end: max(currentPeriod.end, newPeriod.end)
      )
    }

    resultList.append(currentPeriod)
    return resultList
  }

  static func intersectPeriods(list1: [Period], list2: [Period]) -> [Period] {
    var index1 = 0
    var index2 = 0
    var result: [Period] = []

    while index1 < list1.count, index2 < list2.count {
      let period1 = list1[index1]
      let period2 = list2[index2]

      // period1 ends before period2
      if period1.end < period2.start {
        index1 += 1
        continue
      }

      // period2 ends before period1
      if period2.end < period1.start {
        index2 += 1
        continue
      }

      // Intersect periods.
      result.append(Period(
        start: max(period1.start, period2.start),
        end: min(period1.end, period2.end)
      ))

      if period1.end > period2.end {
        index2 += 1
      } else {
        index1 += 1
      }
    }

    return result
  }

  static func negatePeriods(list: [Period]) -> [Period] {
    var result: [Period] = []
    var previousEnd = Date.distantPast

    for period in list {
      if period.start == Date.distantPast {
        previousEnd = period.end
        continue
      }

      result.append(Period(start: previousEnd, end: period.start))
      previousEnd = period.start
    }

    if previousEnd != Date.distantFuture {
      result.append(Period(start: previousEnd, end: Date.distantFuture))
    }

    return result
  }
}

struct ClaimResult {
  var canClaimNow: Bool
  var expired: Bool
  var conflict: Bool
  var startPeriod: Date?
  var endPeriod: Date?
}
