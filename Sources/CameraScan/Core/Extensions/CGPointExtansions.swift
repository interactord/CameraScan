import UIKit

extension CGPoint {

  /// - Note: Returns a rectangle of a given size surounding the point.
  func surroundingSqure(size: CGFloat) -> CGRect {
    .init(x: x - size / 2.0, y: y - size / 2, width: size, height: size)
  }

  /// - Note: Checks wether this point is within a given distance of another point.
  func isWithin(delta: CGFloat, point: CGPoint) -> Bool {
    let vX = abs(x - point.x) <= delta
    let vY = abs(y - point.y) <= delta
    return vX && vY
  }

  /// - Note: Returns the same `CGPoint` in the cartesian coordinate system.
  func cartesian(height: CGFloat) -> CGPoint {
    .init(x: x, y: height - y)
  }

  /// - Note: Returns the distance between two points
  func distance(point: CGPoint) -> CGFloat {
    let diffX = x - point.x
    let diffY = y - point.y
    return hypot(diffX, diffY)
  }

  /// - Note:  Returns the closest corner from the point
  func closestCorner(quad: Quadrilateral) -> CornerPosition {
    closestCorner(cornerPoint: quad.cornerPoint)
  }

  /// - Note:  Returns the closest corner from the point
  func closestCorner(cornerPoint: Quadrilateral.CornerPoint) -> CornerPosition {
    var closestCorner = CornerPosition.topLeft

    if distance(point: cornerPoint.topRight) < distance(point: cornerPoint.topLeft) {
      closestCorner = .topRight
    }

    if distance(point: cornerPoint.bottomRight) < distance(point: cornerPoint.topRight) {
      closestCorner = .bottomRight
    }

    if distance(point: cornerPoint.bottomRight) < distance(point: cornerPoint.bottomLeft) {
      closestCorner = .bottomLeft
    }

    return closestCorner
  }
}
