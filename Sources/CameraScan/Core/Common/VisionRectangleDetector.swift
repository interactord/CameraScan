import CoreImage
import Foundation
import Vision

// MARK: - VisionRectangleDetector

enum VisionRectangleDetector {

  static func rectangle(pixelBuffer: CVPixelBuffer, completion: @escaping ((Quadrilateral?) -> Void)) {
    Self.completeImage(
      request: .init(cvPixelBuffer: pixelBuffer, options: [:]),
      size: .init(
        width: CGFloat(CVPixelBufferGetWidth(pixelBuffer)),
        height: CGFloat(CVPixelBufferGetHeight(pixelBuffer))),
      completion: completion)
  }

  static func rectangle(image: CIImage, completion: @escaping ((Quadrilateral?) -> Void)) {
    Self.completeImage(
      request: .init(ciImage: image, options: [:]),
      size: image.extent.size,
      completion: completion)
  }

  static func rectangle(image: CIImage, orientation: CGImagePropertyOrientation, completion: @escaping ((Quadrilateral?) -> Void)) {
    Self.completeImage(
      request: .init(ciImage: image, orientation: orientation, options: [:]),
      size: image.oriented(orientation).extent.size,
      completion: completion)
  }
}

extension VisionRectangleDetector {
  fileprivate static func completeImage(request: VNImageRequestHandler, size: CGSize, completion: @escaping ((Quadrilateral?) -> Void)) {
    let rectangleDetectionRequest: VNDetectRectanglesRequest = {
      let rectDetectRequest = VNDetectRectanglesRequest { request, error in
        guard error == nil, let results = request.results as? [VNRectangleObservation], !results.isEmpty else {
          return completion(.none)
        }

        let quads: [Quadrilateral] = results.map(Quadrilateral.init)
        guard let biggest = quads.max(by: { $0.perimeter < $1.perimeter }) else {
          return completion(.none)
        }

        let transform = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        completion(biggest.apply(transform: transform))
      }

      rectDetectRequest.minimumConfidence = 0.8
      rectDetectRequest.maximumObservations = 15
      rectDetectRequest.minimumAspectRatio = 0.3

      return rectDetectRequest
    }()

    do {
      try request.perform([rectangleDetectionRequest])
    } catch {
      completion(.none)
      return
    }
  }
}
