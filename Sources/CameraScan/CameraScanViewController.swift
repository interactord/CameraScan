import AVFoundation
import Combine
import UIKit

// MARK: - CameraScanViewOutputDelegate

public protocol CameraScanViewOutputDelegate: AnyObject {
  func captureImage(result: Result<(UIImage, Quadrilateral?), CameraScanError>)
}

// MARK: - CameraScanViewController

public final class CameraScanViewController: UIViewController {

  // MARK: Lifecycle

  public init() {
    super.init(nibName: .none, bundle: .none)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public weak var delegate: CameraScanViewOutputDelegate?

  public var isAutoScanEnabled: Bool = CaptureSession.current.isAutoScanEnabled {
    didSet {
      CaptureSession.current.isAutoScanEnabled = isAutoScanEnabled
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    prepareUI()
    applyLayout()
    applyBinding()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    videoPreviewLayer.frame = view.layer.bounds
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
    CaptureSession.current.isEditing = false
    captureSessionManager?.start()
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
    captureSessionManager?.stop()
  }

  // MARK: Private

  private var captureSessionManager: CaptureSessionManager?
  private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
  private let quadView: QuadrilateralView = {
    let view = QuadrilateralView()
    view.editable = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private var cancellable = Set<AnyCancellable>()

}

extension CameraScanViewController {

  // MARK: Public

  public func capture() {
    captureSessionManager?.capturePhoto()
  }

  // MARK: Private

  private func prepareUI() {
    view.backgroundColor = .darkGray
    captureSessionManager = .init(videoPreviewLayer: videoPreviewLayer)
    captureSessionManager?.delegate = self
  }

  private func applyLayout() {
    view.layer.addSublayer(videoPreviewLayer)
    view.addSubview(quadView)

    NSLayoutConstraint.activate([
      quadView.topAnchor.constraint(equalTo: view.topAnchor),
      view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
      view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
      quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    ])
  }

  private func applyBinding() {
    NotificationCenter.default
      .publisher(for: .AVCaptureDeviceSubjectAreaDidChange, object: .none)
      .map { _ in Void() }
      .sink(receiveValue: { [weak self] _ in
        guard let self = self else { return }
        do {
          try CaptureSession.current.resetFocusToAuto()
        } catch {
          guard let captureSessionManager = self.captureSessionManager else { return }
          captureSessionManager.delegate?
            .captureSessionManager(captureSessionManager, didFail: .inputDevice)
          return
        }
      })
      .store(in: &cancellable)
  }

}

// MARK: RectangleDetectionDelegateProtocol

extension CameraScanViewController: RectangleDetectionDelegateProtocol {
  func didStartCapturingPicture(sessionManager: CaptureSessionManager) {
    sessionManager.stop()
  }

  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, imageSize: CGSize) {
    guard let quad = quad else { return quadView.removeQuadrilateral() }

    let portaitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
    let scaledTransform = CGAffineTransform.scale(from: portaitImageSize, aspectFillSize: quadView.bounds.size)
    let scaledImageSize = imageSize.applying(scaledTransform)
    let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
    let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(.init(rotationAngle: CGFloat.pi / 2.0))
    let translationTransform = CGAffineTransform.translate(fromRect: imageBounds, toRect: quadView.bounds)
    let transformedQuad = quad.apply(transforms: [scaledTransform, rotationTransform, translationTransform])
    quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
  }

  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePricture image: UIImage, quad: Quadrilateral?) {
    delegate?.captureImage(result: .success((image, quad)))
  }

  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFail error: CameraScanError) {
    delegate?.captureImage(result: .failure(error))
  }

}

extension CGAffineTransform {

  fileprivate static func scale(from fromSize: CGSize, aspectFillSize toSize: CGSize) -> Self {
    let scale = max(toSize.width / fromSize.width, toSize.height / fromSize.height)
    return .init(scaleX: scale, y: scale)
  }

  fileprivate static func translate(fromRect: CGRect, toRect: CGRect) -> Self {
    .init(
      translationX: toRect.midX - fromRect.midX,
      y: toRect.midY - fromRect.midY)
  }
}
