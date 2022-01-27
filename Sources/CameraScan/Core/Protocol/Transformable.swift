import UIKit

// MARK: - Transformable

protocol Transformable {
  func apply(transform: CGAffineTransform) -> Self
}

extension Transformable {
  func apply(transforms: [CGAffineTransform]) -> Self {
    var transformableObject = self

    transforms.forEach {
      transformableObject = transformableObject.apply(transform: $0)
    }

    return transformableObject
  }

}
