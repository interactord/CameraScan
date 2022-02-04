import CameraScan
import SwiftUI

// MARK: - FlatImageView

struct FlatImageView: View {

  @State private(set) var image: UIImage

  init(image: UIImage) {
    self.image = image
  }

  var body: some View {
    VStack {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: .zero, maxWidth: .infinity)
      Button(action: {

      }) {
        Text("Ratate")
      }
    }
  }
}

extension UIImage {
  /// - Note: Rotate the image by the given angle, and perform other transformations based on the passed in options.

  fileprivate func rotated(angle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
    guard let cgImage = cgImage else { return .none }

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

      let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
      let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
      renderContext.cgContext.scaleBy(x: .init(x), y: .init(y))

      let origin = CGPoint(x: -cgImageSize.width / 2.0, y: -cgImageSize.height / 2.0)
      let drawRect = CGRect(origin: origin, size: cgImageSize)
      renderContext.cgContext.draw(cgImage, in: drawRect)
    }

    return newImage
  }
}
