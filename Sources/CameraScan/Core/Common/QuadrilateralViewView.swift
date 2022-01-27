import AVFoundation
import UIKit

// MARK: - QuadrilateralView

final class QuadrilateralView: UIView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    applyLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var editable = false {
    didSet {
      cornerViews.forEach { $0.isHidden = !editable }
      quadLayer.fillColor = editable
        ? UIColor(white: .zero, alpha: 0.6).cgColor
        : UIColor(white: 1.0, alpha: 0.5).cgColor
      guard let quad = quad else { return }
      draw(quad: quad, animated: false)
      zip(cornerViews, quad.cornerPoint.list).forEach {
        $0.0.center = $0.1
      }
    }
  }

  public var strokeColor: CGColor? {
    didSet {
      quadLayer.strokeColor = strokeColor
      cornerViews.forEach { $0.strokeColor = strokeColor }
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard quadLayer.frame != bounds else { return }

    quadLayer.frame = bounds
    drawQuadrilateral(quad: quad, animated: false)
  }

  // MARK: Internal

  /// - Note: The quadrilateral drawn on the view.
  private(set) var quad: Quadrilateral?

  // MARK: Private

  private struct Const {
    static let highlightedCornerViewSize = CGSize(width: 75.0, height: 75.0)
    static let cornerViewSize = CGSize(width: 20.0, height: 20.0)
  }

  private let quadLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.strokeColor = UIColor.white.cgColor
    layer.lineWidth = 1.0
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

  private let cornerViews: [EditScanCornerView] = {
    let position: [CornerPosition] = [
      CornerPosition.topLeft,
      CornerPosition.topRight,
      CornerPosition.bottomRight,
      CornerPosition.bottomLeft,
    ]
    let rect = CGRect(origin: .zero, size: .init(width: 75, height: 75))
    return position.map {
      .init(frame: rect, position: $0)
    }
  }()

  private var isHighlighted = false {
    didSet(oldValue) {
      guard oldValue != isHighlighted else { return }
      quadLayer.fillColor = isHighlighted
        ? UIColor.clear.cgColor
        : UIColor(white: .zero, alpha: 0.6).cgColor
      isHighlighted
        ? bringSubviewToFront(quadView)
        : sendSubviewToBack(quadView)
    }
  }

}

extension QuadrilateralView {

  // MARK: Internal

  func removeQuadrilateral() {
    quadLayer.path = .none
    quadLayer.isHidden = true
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

    let diffSize = Const.highlightedCornerViewSize.subtraction(size: Const.cornerViewSize).half
    let origin = CGPoint(
      x: cornerView.frame.origin.x - diffSize.width,
      y: cornerView.frame.origin.y - diffSize.height)
    cornerView.frame = .init(origin: origin, size: Const.highlightedCornerViewSize)
    cornerView.highlight(image: image)
  }

  func resetHighlightCornerViews() {
    isHighlighted = false
    cornerViews.forEach { [weak self] in
      self?.resetHighlight(cornerView: $0)
    }
  }

  // MARK: Private

  private func resetHighlight(cornerView: EditScanCornerView) {
    cornerView.reset()

    let diffSize = cornerView.frame.size.subtraction(size: Const.cornerViewSize).half
    let origin = CGPoint(
      x: cornerView.frame.origin.x + diffSize.width,
      y: cornerView.frame.origin.y + diffSize.height)
    cornerView.frame = .init(origin: origin, size: Const.cornerViewSize)
    cornerView.setNeedsDisplay()
  }

  private func getCornerView(by position: CornerPosition) -> EditScanCornerView? {
    cornerViews.first(where: { $0.position == position })
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
    quadView.layer.addSublayer(quadLayer)
  }

  private func draw(quad: Quadrilateral?, animated: Bool) {
    guard let quad = quad else { return }

    var path = quad.path
    if editable {
      path = path.reversing()
      let rectPath = UIBezierPath(rect: bounds)
      path.append(rectPath)
    }

    if animated == true {
      let pathAnimation = CABasicAnimation(keyPath: "path")
      pathAnimation.duration = 0.2
      quadLayer.add(pathAnimation, forKey: "path")
    }

    quadLayer.path = path.cgPath
    quadLayer.isHidden = false
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
    case .bottomLeft:
      quad.cornerPoint.bottomLeft = position
    case .bottomRight:
      quad.cornerPoint.bottomRight = position
    }

    return quad
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
