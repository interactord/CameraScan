import SwiftUI
import UIKit

// MARK: - ImageDetactionFunctorable

public protocol ImageDetactionFunctorable {
  func detact(image: UIImage, completion: @escaping (Quadrilateral?) -> Void)
}

// MARK: - ImageDetactionFunctor

public struct ImageDetactionFunctor: ImageDetactionFunctorable {

  public init() {}

  public func detact(image: UIImage, completion: @escaping (Quadrilateral?) -> Void) {
    guard let ciImage = CIImage(image: image) else { return }
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    let orientedImage = ciImage.oriented(forExifOrientation: .init(orientation.rawValue))

    VisionRectangleDetector.rectangle(image: ciImage, orientation: orientation) { quad in
      completion(quad?.toCartesian(height: orientedImage.extent.height))
    }
  }
}

extension CGImagePropertyOrientation {
  fileprivate init(_ uiOrientation: UIImage.Orientation) {
    switch uiOrientation {
    case .up:
      self = .up
    case .upMirrored:
      self = .upMirrored
    case .down:
      self = .down
    case .downMirrored:
      self = .downMirrored
    case .left:
      self = .left
    case .leftMirrored:
      self = .leftMirrored
    case .right:
      self = .right
    case .rightMirrored:
      self = .rightMirrored
    @unknown default:
      assertionFailure("Unknow orientation, falling to default")
      self = .right
    }
  }
}
