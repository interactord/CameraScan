import AVFoundation
import UIKit

// MARK: - QuadrilateralView

final class QuadrilateralView: UIView {

  // MARK: Lifecycle

  init(
    scanBoxingLayer: DesignConfig.BoxLayer = .defaultValue(),
    scanEditLayer: DesignConfig.EditPointLayer = .defaultValue())
  {
    self.scanBoxingLayer = scanBoxingLayer
    self.scanEditLayer = scanEditLayer
    super.init(frame: .zero)
    applyLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public let scanBoxingLayer: DesignConfig.BoxLayer
  public let scanEditLayer: DesignConfig.EditPointLayer

  public var editable = false {
    didSet {
      cornerViews.forEach { $0.isHidden = !editable }

      backgroundQuadLayer.fillColor = scanBoxingLayer.apply(isEditing: editable).fillColor.cgColor
      foregroundQuadLayer.fillColor = UIColor.clear.cgColor
      foregroundQuadLayer.strokeColor = scanBoxingLayer.apply(isEditing: editable).strokeColor.cgColor
      foregroundQuadLayer.lineWidth = scanEditLayer.apply(isEditing: editable).style.strokeWidth

      guard let quad = quad else { return }
      draw(quad: quad, animated: false)
      zip(cornerViews, quad.cornerPoint.list).forEach {
        $0.0.center = $0.1
      }
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard backgroundQuadLayer.frame != bounds else { return }

    backgroundQuadLayer.frame = bounds
    foregroundQuadLayer.frame = bounds
    drawQuadrilateral(quad: quad, animated: false)
  }

  // MARK: Internal

  /// - Note: The quadrilateral drawn on the view.
  private(set) var quad: Quadrilateral?

  // MARK: Private

  private lazy var backgroundQuadLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.opacity = 1.0
    layer.isHidden = true
    return layer
  }()

  private lazy var foregroundQuadLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.opacity = 1.0
    layer.isHidden = true
    return layer
  }()

  /// - Note: We want the corner views to be displayed under the outline of the quadrilateral. Because of that, we need the quadrilateral to be drawn on a UIView above them.
  private let quadView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var cornerViews: [EditScanCornerView] = {
    let position: [CornerPosition] = [
      CornerPosition.topLeft,
      CornerPosition.topRight,
      CornerPosition.bottomRight,
      CornerPosition.bottomLeft,
    ]
    let rect = CGRect(origin: .zero, size: scanEditLayer.noEdit.squareSize.convertSize())
    return position.map { [weak self] in
      .init(frame: rect, position: $0, scanEditLayer: self?.scanEditLayer ?? .defaultValue())
    }
  }()

  private var isHighlighted = false {
    didSet(oldValue) {
      guard oldValue != isHighlighted else { return }
      backgroundQuadLayer.fillColor = isHighlighted ? UIColor.clear.cgColor : scanBoxingLayer.edit.fillColor.cgColor
      foregroundQuadLayer.fillColor = UIColor.clear.cgColor
      foregroundQuadLayer.strokeColor = scanBoxingLayer.edit.strokeColor.cgColor
      foregroundQuadLayer.lineWidth = scanBoxingLayer.edit.strokeWidth

      isHighlighted
        ? bringSubviewToFront(quadView)
        : sendSubviewToBack(quadView)
    }
  }

}

extension QuadrilateralView {

  // MARK: Internal

  func removeQuadrilateral() {
    backgroundQuadLayer.path = .none
    backgroundQuadLayer.isHidden = true
    foregroundQuadLayer.path = .none
    foregroundQuadLayer.isHidden = true
  }

  func drawQuadrilateral(quad: Quadrilateral?, animated: Bool) {
    guard let quad = quad else { return }

    self.quad = quad
    draw(quad: quad, animated: animated)
    if editable {
      cornerViews.forEach { $0.isHidden = false }
      zip(cornerViews, quad.cornerPoint.list).forEach {
        $0.0.center = $0.1
      }
    }
  }

  func move(cornerView: EditScanCornerView, point: CGPoint) {
    guard let quad = quad else { return }
    let valid = valid(point: point, cornerViewSize: cornerView.bounds.size, inView: self)
    cornerView.center = valid

    let updateQuad = update(quad: quad, position: valid, corner: cornerView.position)
    self.quad = updateQuad
    draw(quad: updateQuad, animated: false)
  }

  func highlightCorner(position: CornerPosition, image: UIImage) {
    guard editable, let cornerView = getCornerView(by: position) else { return }
    isHighlighted = true

    guard cornerView.isHighlighted == false else {
      cornerView.highlight(image: image)
      return
    }

    let diffSize = scanEditLayer.edit.squareSize.convertSize()
      .subtraction(size: scanEditLayer.noEdit.squareSize.convertSize()).half
    let origin = CGPoint(
      x: cornerView.frame.origin.x - diffSize.width,
      y: cornerView.frame.origin.y - diffSize.height)
    cornerView.frame = .init(origin: origin, size: scanEditLayer.edit.squareSize.convertSize())
    cornerView.highlight(image: image)
  }

  func resetHighlightCornerViews() {
    isHighlighted = false
    cornerViews.forEach { [weak self] in
      self?.resetHighlight(cornerView: $0)
    }
  }

  func getCornerView(by position: CornerPosition) -> EditScanCornerView? {
    cornerViews.first(where: { $0.position == position })
  }

  // MARK: Private

  private func resetHighlight(cornerView: EditScanCornerView) {
    cornerView.reset()

    let diffSize = cornerView.frame.size
      .subtraction(size: scanEditLayer.noEdit.squareSize.convertSize()).half
    let origin = CGPoint(
      x: cornerView.frame.origin.x + diffSize.width,
      y: cornerView.frame.origin.y + diffSize.height)
    cornerView.frame = .init(origin: origin, size: scanEditLayer.noEdit.squareSize.convertSize())
    cornerView.setNeedsDisplay()
  }

  private func applyLayout() {
    addSubview(quadView)
    cornerViews.forEach {[weak self] in
      self?.addSubview($0)
    }
    NSLayoutConstraint.activate([
      quadView.topAnchor.constraint(equalTo: topAnchor),
      quadView.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
      trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
    ])
    quadView.layer.addSublayer(backgroundQuadLayer)
    quadView.layer.addSublayer(foregroundQuadLayer)
  }

  private func draw(quad: Quadrilateral, animated: Bool) {
    var path = quad.path

    if editable {
      path = path.reversing()
      let rectPath = UIBezierPath(rect: bounds)
      path.append(rectPath)
    }

    if animated == true {
      let pathAnimation = CABasicAnimation(keyPath: "path")
      pathAnimation.duration = 0.2
      backgroundQuadLayer.add(pathAnimation, forKey: "path")
      foregroundQuadLayer.add(pathAnimation, forKey: "path")
    }

    backgroundQuadLayer.path = path.cgPath
    backgroundQuadLayer.isHidden = false

    foregroundQuadLayer.path = quad.path.cgPath
    foregroundQuadLayer.isHidden = false
  }

  private func valid(point: CGPoint, cornerViewSize: CGSize, inView view: UIView) -> CGPoint {

    var valid = point

    if point.x > view.bounds.width {
      valid.x = view.bounds.width
    } else if point.x < .zero {
      valid.x = .zero
    }

    if point.y > view.bounds.height {
      valid.y = view.bounds.height
    } else if point.y < .zero {
      valid.y = .zero
    }

    return valid
  }

  private func update(quad: Quadrilateral, position: CGPoint, corner: CornerPosition) -> Quadrilateral {
    var quad = quad
    switch corner {
    case .topLeft:
      quad.cornerPoint.topLeft = position
    case .topRight:
      quad.cornerPoint.topRight = position
    case .bottomRight:
      quad.cornerPoint.bottomRight = position
    case .bottomLeft:
      quad.cornerPoint.bottomLeft = position
    }

    return quad
  }

}

extension CGFloat {
  fileprivate func convertSize() -> CGSize {
    .init(width: self, height: self)
  }
}

extension CGSize {
  fileprivate var half: CGSize {
    .init(width: width / 2.0, height: height / 2.0)
  }

  fileprivate func subtraction(size: CGSize) -> Self {
    .init(width: width - size.width, height: height - size.height)
  }

}
