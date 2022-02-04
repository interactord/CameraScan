import SwiftUI
import UIKit

// MARK: - ImageDetactionFunctorable

public protocol ImageDetactionFunctorable {
  func detact(image: UIImage, completion: @escaping (Quadrilateral?) -> Void)
  func rotate(image: UIImage, angle: Measurement<UnitAngle>) -> UIImage?
}

// MARK: - ImageDetactionFunctor

public struct ImageDetactionFunctor: ImageDetactionFunctorable {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func detact(image: UIImage, completion: @escaping (Quadrilateral?) -> Void) {
    guard let ciImage = CIImage(image: image) else { return }
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    let orientedImage = ciImage.oriented(forExifOrientation: .init(orientation.rawValue))

    VisionRectangleDetector.rectangle(image: ciImage, orientation: orientation) { quad in
      completion(quad?.toCartesian(height: orientedImage.extent.height))
    }
  }

  public func rotate(image: UIImage, angle: Measurement<UnitAngle>) -> UIImage? {
    guard let cgImage = image.cgImage else { return  .none }

    let rotationRadians = CGFloat(angle.converted(to: .radians).value)
    let transform = CGAffineTransform(rotationAngle: rotationRadians)
    let cgImageSize = CGSize(width: cgImage.width, height: cgImage.height)
    var rect = CGRect(origin: .zero, size: cgImageSize).applying(transform)
    rect.origin = .zero

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1

    let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)

    let newImage = renderer.image { renderContext in
      renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
      renderContext.cgContext.rotate(by: rotationRadians)
      renderContext.cgContext.scaleBy(x: 1.0, y: -1.0)

      let origin = CGPoint(x: -cgImageSize.width / 2.0, y: -cgImageSize.height / 2.0)
      let drawRect = CGRect(origin: origin, size: cgImageSize)
      renderContext.cgContext.draw(cgImage, in: drawRect)
    }

    return newImage
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
