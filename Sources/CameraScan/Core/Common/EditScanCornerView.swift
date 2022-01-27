import UIKit

// MARK: - EditScanCornerView

/// - Note: A UIView used by corners of a quadrilateral that is aware of its position.
final class EditScanCornerView: UIView {

  // MARK: Lifecycle

  init(frame: CGRect, position: CornerPosition) {
    self.position = position
    super.init(frame: frame)
    prepareUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var strokeColor: CGColor? {
    didSet {
      circleLayer.strokeColor = strokeColor
    }
  }

  // MARK: Internal

  let position: CornerPosition

  private(set) var isHighlighted = false

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    let path: UIBezierPath = .init(ovalIn: rect.insetBy(dx: circleLayer.lineWidth, dy: circleLayer.lineWidth))
    circleLayer.frame = rect
    circleLayer.path = path.cgPath

    image?.draw(in: rect)
  }

  // MARK: Private

  private var image: UIImage?
  private lazy var circleLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.clear.cgColor
    layer.strokeColor = UIColor.white.cgColor
    layer.lineWidth = 1.0

    return layer
  }()

}

extension EditScanCornerView {

  // MARK: Internal

  func highlight(image: UIImage) {
    isHighlighted = true
    self.image = image
    setNeedsDisplay()
  }

  func reset() {
    isHighlighted = false
    image = .none
  }

  // MARK: Private

  private func prepareUI() {
    backgroundColor = .clear
    clipsToBounds = false
    layer.addSublayer(circleLayer)
  }

}
