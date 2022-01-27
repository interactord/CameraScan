import UIKit

// MARK: - EditScanCornerView

/// - Note: A UIView used by corners of a quadrilateral that is aware of its position.
final class EditScanCornerView: UIView {

  // MARK: Lifecycle

  init(
    frame: CGRect,
    position: CornerPosition,
    scanEditLayer: DesignConfig.EditPointLayer)
  {
    self.position = position
    self.scanEditLayer = scanEditLayer
    super.init(frame: frame)
    prepareUI()
    apply(isHighlighted: false)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public let scanEditLayer: DesignConfig.EditPointLayer

  public var strokeColor: CGColor? {
    didSet {
      circleLayer.strokeColor = strokeColor
    }
  }

  // MARK: Internal

  let position: CornerPosition

  private(set) var isHighlighted = false {
    didSet {
      apply(isHighlighted: isHighlighted)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.width / 2.0
  }

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
    layer.lineWidth = 1.0
    layer.fillColor = UIColor.clear.cgColor
    return layer
  }()

  private func apply(isHighlighted: Bool) {
    circleLayer.strokeColor = scanEditLayer.apply(isEditing: isHighlighted).style.strokeColor.cgColor
    circleLayer.lineWidth = scanEditLayer.apply(isEditing: isHighlighted).style.strokeWidth
    circleLayer.fillColor = scanEditLayer.apply(isEditing: isHighlighted).style.fillColor.cgColor
  }

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
    clipsToBounds = true
    layer.addSublayer(circleLayer)
  }

}
