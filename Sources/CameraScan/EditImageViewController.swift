import AVFoundation
import SwiftUI
import UIKit

// MARK: - EditImageViewDelegate

public protocol EditImageViewDelegate: AnyObject {
  func cropped(image: UIImage)
}

// MARK: - EditImageViewController

public final class EditImageViewController: UIViewController {

  // MARK: Lifecycle

  public init(
    image: UIImage,
    quad: Quadrilateral?,
    isRotateImage: Bool)
  {
    self.image = isRotateImage ? image.applyingPortraitOrientation() : image
    self.quad = quad ?? .defaultValueByOffset(image: image)
    super.init(nibName: .none, bundle: .none)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var isCropped: Bool = false {
    didSet {
      guard isCropped else { return }
      cropImage()
      isCropped = false
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    applyLayout()
    prepareUI()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    adjustQuadViewLayout()
    displayQuad()
  }

  // MARK: Internal

  weak var delegate: EditImageViewDelegate?

  // MARK: Private

  private var image: UIImage
  private var quad: Quadrilateral
  private lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.clipsToBounds = true
    view.isOpaque = true
    view.image = image
    view.backgroundColor = .black
    view.contentMode = .scaleAspectFit
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var quadView: QuadrilateralView = {
    let view = QuadrilateralView()
    view.editable = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private var zoomGestureController: ZoomGestureController!
  private var quadViewWidthConstraint = NSLayoutConstraint()
  private var quadViewHeightContraint = NSLayoutConstraint()
}

extension EditImageViewController {

  // MARK: Public

  public func cropImage() {
    guard let quad = quadView.quad, let ciImage = CIImage(image: image) else { return }

    guard let cgOrientation = CGImagePropertyOrientation(rawValue: .init(image.imageOrientation.rawValue)) else { return }
    let orientedImage = ciImage.oriented(forExifOrientation: .init(cgOrientation.rawValue))
    let scaledQuad = quad.scale(from: quadView.bounds.size, to: image.size)
    self.quad = scaledQuad

    /// - Note: Cropping
    var cartesianScaledQuad = scaledQuad.toCartesian(height: image.size.height)
    cartesianScaledQuad.reorganize()

    let filtedImage = orientedImage.applyingFilter(FilterKey.filter.rawValue, parameters: [
      FilterKey.topLeft.rawValue: CIVector(cgPoint: cartesianScaledQuad.cornerPoint.bottomLeft),
      FilterKey.topRight.rawValue: CIVector(cgPoint: cartesianScaledQuad.cornerPoint.bottomRight),
      FilterKey.bottomLeft.rawValue: CIVector(cgPoint: cartesianScaledQuad.cornerPoint.topLeft),
      FilterKey.bottomRight.rawValue: CIVector(cgPoint: cartesianScaledQuad.cornerPoint.topRight),
    ])

    delegate?.cropped(image: .make(ciImage: filtedImage))

  }

  public func rotateImage() {
    reloadImage(angle: .init(value: 90, unit: .degrees))
  }

  // MARK: Private

  private enum FilterKey: String {
    case filter = "CIPerspectiveCorrection"
    case topLeft = "inputTopLeft"
    case topRight = "inputTopRight"
    case bottomLeft = "inputBottomLeft"
    case bottomRight = "inputBottomRight"
  }

  private func addLongGesture(controller: ZoomGestureController?) {
    guard let controller = controller else { return }
    let gesture = UILongPressGestureRecognizer(target: controller, action: #selector(controller.handle(pan:)))

    gesture.minimumPressDuration = 0
    view.addGestureRecognizer(gesture)
  }

  private func reloadImage(angle: Measurement<UnitAngle>) {
    guard let newImage = image.rotated(angle: angle) else { return }
    let newQuad = Quadrilateral.defaultValueByOffset(image: newImage)

    image = newImage
    imageView.image = image
    quad = newQuad
    adjustQuadViewLayout()
    displayQuad()

    zoomGestureController = .init(image: image, quadView: quadView)
    addLongGesture(controller: zoomGestureController)
  }

  /// - Note:
  ///   - The quadView should be lined up on top of the actual image displayed by the imageView.
  ///   - Since there is no way to know the size of that image before run time, we adjust the constraints to make sure that the quadView is on top of the displayed image.
  private func adjustQuadViewLayout() {
    let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
    quadViewWidthConstraint.constant = frame.size.width
    quadViewHeightContraint.constant = frame.size.height
  }

  /// - Note: Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
  private func displayQuad() {
    let imageSize = image.size
    let size = CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightContraint.constant)
    let imageFrame = CGRect(origin: quadView.frame.origin, size: size)
    let scaleTransform = CGAffineTransform.scale(from: imageSize, aspectFillSize: imageFrame.size)
    let transformedQuad = quad.apply(transforms: [scaleTransform])
    quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
  }

  private func applyLayout() {
    view.addSubview(imageView)
    view.addSubview(quadView)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
    ])

    quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: .zero)
    quadViewHeightContraint = quadView.heightAnchor.constraint(equalToConstant: .zero)

    NSLayoutConstraint.activate([
      quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      quadViewWidthConstraint,
      quadViewHeightContraint,
    ])
  }

  private func prepareUI() {
    zoomGestureController = .init(image: image, quadView: quadView)
    addLongGesture(controller: zoomGestureController)
  }

}

extension Quadrilateral {
  /// - Note: Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
  fileprivate static func defaultValue(image: UIImage) -> Self {
    .init(cornerPoint: .init(
      topLeft: .init(x: image.size.width / 3.0, y: image.size.height / 3.0),
      topRight: .init(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0),
      bottomLeft: .init(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0),
      bottomRight: .init(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)))
  }

  /// - Note: Generates a `Quadrilateral` object that's cover all of image.
  fileprivate static func defaultValueByOffset(image: UIImage, offset: CGFloat = 75) -> Self {
    .init(cornerPoint: .init(
      topLeft: .init(x: offset, y: offset),
      topRight: .init(x: image.size.width - offset, y: offset),
      bottomLeft: .init(x: offset, y: image.size.height - offset),
      bottomRight: .init(x: image.size.width - offset, y: image.size.height - offset)))
  }
}

extension UIImage {

  // MARK: Internal

  /// - Note: Returns the same image with a portrait orientation.
  func applyingPortraitOrientation() -> UIImage {
    switch imageOrientation {
    case .up:
      return rotated(angle: .init(value: .pi, unit: .radians)) ?? self
    case .down:
      return rotated(angle: .init(value: .pi, unit: .radians), options: [
        .flipOnHorizontalAxis, .flipOnHorizontalAxis,
      ]) ?? self
    case .left:
      return self
    case .right:
      return rotated(angle: .init(value: .pi / 2.0, unit: .radians)) ?? self
    default:
      return self
    }
  }

  // MARK: Fileprivate

  fileprivate struct RotationOptions: OptionSet {
    let rawValue: Int
    static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
    static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
  }

  fileprivate static func make(ciImage: CIImage) -> UIImage {
    guard let cgImage = CIContext(options: .none).createCGImage(ciImage, from: ciImage.extent) else {
      return .init(ciImage: ciImage, scale: 1.0, orientation: .up)
    }
    return .init(cgImage: cgImage)
  }

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

extension CGAffineTransform {
  fileprivate static func scale(from fromSize: CGSize, aspectFillSize toSize: CGSize) -> Self {
    let scale = max(toSize.width / fromSize.width, toSize.height / fromSize.height)
    return .init(scaleX: scale, y: scale)
  }
}
