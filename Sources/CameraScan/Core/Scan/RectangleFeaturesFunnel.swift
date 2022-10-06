import AVFoundation
import Foundation

// MARK: - RectangleFeaturesFunnel

final class RectangleFeaturesFunnel {

  // MARK: Internal

  /// - Note: The number of times the rectangle has passed the threshold to be auto-scanned
  var currentAutoScanPassCount = 0

  // MARK: Private

  private struct Const {
    /// - Note: The maximum number of rectangles to compare newly added rectangles with. Determines the maximum size of `rectangles`. Increasing this value will impact performance.
    static let maxNumberOfRectangles = 8

    /// - Note:
    ///   - The minimum number of rectangles needed to start making comparisons and determining which rectangle to display. This value should always be inferior than `maxNumberOfRectangles`.
    ///   - A higher value will delay the first time a rectangle is displayed.
    static let minNumberOfRectangles = 3

    /// - Note: The value in pixels used to determine if two rectangle match or not. A higher value will prevent displayed rectangles to be refreshed. On the opposite, a smaller value will make new rectangles be displayed constantly.
    static let matchingThreshold: CGFloat = 40.0

    /// - Note: The minimum number of matching rectangles (within the `rectangle` queue), to be confident enough to display a rectangle.
    static let minNumberOfMatches = 3

    /// - Note: The number of similar rectangles that need to be found to auto scan.
    static let autoScanThreshold = 35

    /// - Note:
    ///     - The value in pixels used to determine if a rectangle is accurate enough to be auto scanned.
    ///     - A higher value means the auto scan is quicker, but the rectangle will be less accurate. On the other hand, the lower the value, the longer it'll take for the auto scan, but it'll be way more accurate
    static let autoScanMatchingThreshold: CGFloat = 18.0
  }

  /// - Note: The queue of last added rectangles. The first rectangle is oldest one, and the last rectangle is the most recently added one.
  private var rectangles: [RectangleMatch] = []

}

extension RectangleFeaturesFunnel {

  // MARK: Internal

  /// - Note:
  ///   - Add a rectangle to the funnel, and if a new rectangle should be displayed, the completion block will be called.
  ///   - The algorithm works the following way:
  ///     1. Makes sure that the funnel has been fed enough rectangles
  ///     2. Removes old rectangles if needed
  ///     3. Compares all of the recently added rectangles to find out which one match each other
  ///     4. Within all of the recently added rectangles, finds the "best" one (@see `best(current:) -> RectangleMatch?`)
  ///     5. If the best rectangle is different than the currently displayed rectangle, informs the listener that a new rectangle should be displayed
  ///       5a. The currentAutoScanPassCount is incremented every time a new rectangle is displayed. If it passes the autoScanThreshold, we tell the listener to scan the document.
  func add(feature: Quadrilateral, current: Quadrilateral?, completion: (AddResult, Quadrilateral) -> Void) {
    let match = RectangleMatch(feature: feature)
    rectangles.append(match)

    guard rectangles.count >= Const.minNumberOfMatches else { return }

    if rectangles.count > Const.maxNumberOfRectangles {
      rectangles.removeFirst()
    }

    updateMatches()

    guard let best = best(current: current) else { return }

    if let prev = current, best.feature.isWithin(distance: Const.autoScanMatchingThreshold, feature: prev) {
      currentAutoScanPassCount += 1
      if currentAutoScanPassCount > Const.autoScanThreshold {
        currentAutoScanPassCount = .zero
        completion(.showAndAutoScan, best.feature)
      }
    } else {
      completion(.showOnly, best.feature)
    }

  }

  // MARK: Private

  /// - Note:
  ///   - Determines which rectangle is best to displayed.
  ///   - The criteria used to find the best rectangle is its matching score.
  ///   - If multiple rectangles have the same matching score, we use a tie breaker to find the best rectangle (@see breakTie(rect1:, rect2:, current:)).
  private func best(current: Quadrilateral?) -> RectangleMatch? {
    var bestMatch: RectangleMatch?
    guard !rectangles.isEmpty else { return .none }
    rectangles.reversed().forEach { rectangle in
      guard let best = bestMatch else {
        bestMatch = rectangle
        return
      }

      switch rectangle.matchingScore {
      case let x where x > best.matchingScore:
        bestMatch = rectangle
        return

      case let x where x == best.matchingScore:
        guard let current = current else { return }
        bestMatch = breakTie(rect1: best, rect2: rectangle, current: current)

      default:
        break
      }
    }

    return bestMatch
  }

  /// - Note:
  ///   - Breaks a tie between two rectangles to find out which is best to display.
  ///   - The first passed rectangle is returned if no other criteria could be used to break the tie.
  ///   - If the first passed rectangle (rect1) is close to the currently displayed rectangle, we pick it.
  ///   - Otherwise if the second passed rectangle (rect2) is close to the currently displayed rectangle, we pick this one.
  ///   - Finally, if none of the passed in rectangles are close to the currently displayed rectangle, we arbitrary pick the first one.
  private func breakTie(rect1: RectangleMatch, rect2: RectangleMatch, current: Quadrilateral) -> RectangleMatch {
    rect2.feature.isWithin(distance: Const.matchingThreshold, feature: current) ? rect2 : rect1
  }

  /// - Note: Loops through all of the rectangles of the queue, and gives them a score depending on how many they match. @see `RectangleMatch.matchingScore`
  private func updateMatches() {
    guard !rectangles.isEmpty else { return }
    rectangles.forEach { $0.matchingScore = 1 }
    for (i, curr) in rectangles.enumerated() {
      for (j, next) in rectangles.enumerated() {
        if j > i && curr.matches(rectangle: next.feature, threshold: Const.matchingThreshold) {
          curr.matchingScore += 1
          next.matchingScore += 1
        }
      }
    }
  }
}

extension RectangleFeaturesFunnel {

  // MARK: Internal

  enum AddResult {
    case showAndAutoScan
    case showOnly
  }

  // MARK: Private

  private final class RectangleMatch: NSObject {

    // MARK: Lifecycle

    init(feature: Quadrilateral) {
      self.feature = feature
    }

    // MARK: Internal

    let feature: Quadrilateral
    var matchingScore: Int = .zero

    override var description: String {
      "Matching score: \(matchingScore) - Rectangle: \(feature)"
    }

    /// - Note: Whether the rectangle of this instance is within the distance of the given rectangle.
    func matches(rectangle: Quadrilateral, threshold: CGFloat) -> Bool {
      feature.isWithin(distance: threshold, feature: rectangle)
    }

  }
}
