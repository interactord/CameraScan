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
    guard let orientation = CGImagePropertyOrientation(rawValue: .init(image.imageOrientation.rawValue)) else { return }

    let orientedImage = ciImage.oriented(orientation)

    VisionRectangleDetector.rectangle(image: ciImage, orientation: orientation) { quad in
      completion(quad?.toCartesian(height: orientedImage.extent.height))
    }
  }
}
