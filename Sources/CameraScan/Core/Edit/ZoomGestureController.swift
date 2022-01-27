import AVFoundation
import UIKit

// MARK: - ZoomGestureController

final class ZoomGestureController {

  // MARK: Lifecycle

  init(image: UIImage, quadView: QuadrilateralView) {
    self.image = image
    self.quadView = quadView
  }

  // MARK: Private

  private struct Const {
    static let scaleFactor: CGFloat = 2.5
  }

  private let image: UIImage
  private let quadView: QuadrilateralView
  private var prevPanPosition: CGPoint?
  private var closestCorner: CornerPosition?

}

extension ZoomGestureController {

  // MARK: Internal

  @objc
  func handle(pan: UIGestureRecognizer) {
    guard let drawnQuad = quadView.quad else { return }
    guard pan.state != .ended else { return reset() }

    let position = pan.location(in: quadView)
    let prevPanPosition = self.prevPanPosition ?? position
    let closestCorner = self.closestCorner ?? position.closestCorner(quad: drawnQuad)

    guard let cornerView = quadView.getCornerView(by: closestCorner) else { return }

    let offset = CGAffineTransform(translationX: position.x - prevPanPosition.x, y: position.y - prevPanPosition.y)
    let draggedCornerViewCenter = cornerView.center.applying(offset)

    quadView.move(cornerView: cornerView, point: draggedCornerViewCenter)
    self.prevPanPosition = position
    self.closestCorner = closestCorner

    let scale = image.size.width / quadView.bounds.size.width
    let scaledDraggedCornerViewCenter = CGPoint(
      x: draggedCornerViewCenter.x * scale,
      y: draggedCornerViewCenter.y * scale)

    guard
      let zoomedImage = image
        .scaled(
          point: scaledDraggedCornerViewCenter,
          scaleFactor: Const.scaleFactor,
          size: quadView.bounds.size)
    else { return }

    quadView.highlightCorner(position: closestCorner, image: zoomedImage)
  }

  // MARK: Private

  private func reset() {
    prevPanPosition = .none
    closestCorner = .none
    quadView.resetHighlightCornerViews()
  }
}

extension UIImage {

  /// - Note: Draws a new cropped and scaled (zoomed in) image.
  func scaled(point: CGPoint, scaleFactor: CGFloat, size: CGSize) -> UIImage? {
    guard let cgimage = cgImage else { return .none }

    let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
    let mid = CGPoint(x: point.x - scaledSize.width / 2.0, y: point.y - scaledSize.height / 2.0)
    let newRect = CGRect(origin: mid, size: scaledSize)

    guard let croppedImage = cgimage.cropping(to: newRect) else { return .none }

    return .init(cgImage: croppedImage)
  }
}
