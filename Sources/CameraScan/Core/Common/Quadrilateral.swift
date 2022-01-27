import AVFoundation
import UIKit
import Vision

// MARK: - Quadrilateral

public struct Quadrilateral {

  public var cornerPoint: CornerPoint
}

// MARK: CustomStringConvertible

extension Quadrilateral: CustomStringConvertible {
  public var description: String {
    cornerPoint.description
  }
}

// MARK: Transformable

extension Quadrilateral: Transformable {

  func apply(transform: CGAffineTransform) -> Self {
    .init(cornerPoint: cornerPoint.apply(transform: transform))
  }
}

extension Quadrilateral {

  // MARK: Lifecycle

  init(rawValue: VNRectangleObservation) {
    cornerPoint = .init(
      topLeft: rawValue.topLeft,
      topRight: rawValue.topRight,
      bottomLeft: rawValue.bottomLeft,
      bottomRight: rawValue.bottomRight)
  }

  // MARK: Internal

  /// - Note: The path of the Quadrilateral as a `UIBezierPath`
  var path: UIBezierPath {
    let path = UIBezierPath()
    path.move(to: cornerPoint.topLeft)
    [cornerPoint.topRight, cornerPoint.bottomRight, cornerPoint.bottomLeft]
      .forEach { path.addLine(to: $0) }
    path.close()

    return path
  }

  /// - Note: The perimeter of the Quadrilateral
  var perimeter: Double {
    zip(cornerPoint.list, Array(cornerPoint.list.dropFirst()) + [cornerPoint.topLeft])
      .map{ ($0.0, $0.1) }
      .map { $0.0.distance(point: $0.1) }
      .reduce(Double.zero) { $0 + Double($1) }
  }

  /// - Note: Checks whether the quadrilateral is withing a given distance of another quadrilateral.
  func isWithin(distance: CGFloat, feature: Quadrilateral) -> Bool {
    cornerPoint.isWithin(distance: distance, feature: feature)
  }

  func scale(from fromSize: CGSize, to toSize: CGSize, angle: CGFloat = .zero) -> Self {
    let invertedFromSize = fromSize.inverted(angle: angle)
    let scaledTransform: CGAffineTransform = .init(
      scaleX: toSize.width / invertedFromSize.mapToMagnitude.width,
      y: toSize.height / invertedFromSize.mapToMagnitude.height)
    let transformedModel = apply(transform: scaledTransform)

    guard angle != 0.0 else { return transformedModel }

    let rotationTransform = CGAffineTransform(rotationAngle: angle)
    let fromImageBounds = CGRect(origin: .zero, size: fromSize)
      .applying(scaledTransform)
      .applying(rotationTransform)

    let toImageBounds = CGRect(origin: .zero, size: toSize)
    let translationTransform: CGAffineTransform = .tranlate(from: fromImageBounds, to: toImageBounds)

    return transformedModel
      .apply(transforms: [rotationTransform, translationTransform])
  }

  /// - Note: Converts the current to the cartesian coordinate system (where 0 on the y axis is at the bottom).
  func toCartesian(height: CGFloat) -> Self {
    .init(cornerPoint: cornerPoint.toCartesian(height: height))
  }

  /// - Note: Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
  mutating func reorganize() {
    let points = cornerPoint.list
    let sortY = points.sortByY

    guard sortY.count == 4 else { return }

    let topSortX = Array(sortY[0..<2]).sortByX
    let bottomSortX = Array(sortY[2..<4]).sortByX

    cornerPoint = .init(
      topLeft: topSortX.first ?? .zero,
      topRight: topSortX.last ?? .zero,
      bottomLeft: bottomSortX.first ?? .zero,
      bottomRight: bottomSortX.last ?? .zero)
  }

}

// MARK: Equatable

extension Quadrilateral: Equatable {
  public static func == (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
    lhs.cornerPoint == rhs.cornerPoint
  }
}

extension Quadrilateral {
  public struct CornerPoint: Transformable, CustomStringConvertible, Equatable {

    // MARK: Public

    public var topLeft: CGPoint
    public var topRight: CGPoint
    public var bottomLeft: CGPoint
    public var bottomRight: CGPoint

    public var description: String {
      """
      topLeft -> \(topLeft),
      topRight -> \(topRight),
      bottomLeft -> \(bottomLeft),
      botomRight -> \(bottomRight),
      """
    }

    // MARK: Internal

    var list: [CGPoint] {
      [topLeft, topRight, bottomRight, bottomLeft]
    }

    func apply(transform: CGAffineTransform) -> Self {
      .init(
        topLeft: topLeft.applying(transform),
        topRight: topRight.applying(transform),
        bottomLeft: bottomLeft.applying(transform),
        bottomRight: bottomRight.applying(transform))
    }

    func isWithin(distance: CGFloat, feature: Quadrilateral) -> Bool {
      zip(list, feature.cornerPoint.list)
        .map { ($0.0, $0.1) }
        .first(where: { !$0.0.surroundingSqure(size: distance).contains($0.1) })
        .map(\.0) == .none
    }

    func toCartesian(height: CGFloat) -> Self {
      .init(
        topLeft: topLeft.cartesian(height: height),
        topRight: topRight.cartesian(height: height),
        bottomLeft: bottomLeft.cartesian(height: height),
        bottomRight: bottomRight.cartesian(height: height))
    }
  }
}

extension Collection where Element == CGPoint {
  fileprivate var sortByY: [CGPoint] {
    sorted { $0.y < $1.y }
  }

  fileprivate var sortByX: [CGPoint] {
    sorted { $0.x < $1.x }
  }
}

extension CGSize {
  fileprivate var mapToMagnitude: Self {
    .init(
      width: width <= 0 ? .leastNormalMagnitude : width,
      height: height <= 0 ? .leastNormalMagnitude : height)
  }

  fileprivate func inverted(angle: CGFloat) -> Self {
    guard angle != .zero && angle != .pi else { return self }
    return .init(width: height, height: width)
  }

}

extension CGAffineTransform {
  fileprivate static func tranlate(from fromCenter: CGRect, to toCenter: CGRect) -> Self {
    .init(
      translationX: toCenter.midX - fromCenter.midX,
      y: toCenter.midY - fromCenter.midY)
  }
}
