import Combine
import SwiftUI
import UIKit

// MARK: - CameraScanViewController

public final class CameraScanViewController: UIViewController {

  // MARK: Lifecycle

  public init(scanBoxingLayer: DesignConfig.BoxLayer, scanEditLayer: DesignConfig.EditPointLayer, onCaptureCompletion: @escaping () -> Void) {
    self.scanBoxingLayer = scanBoxingLayer
    self.scanEditLayer = scanEditLayer
    self.onCaptureCompletion = onCaptureCompletion
    super.init(nibName: .none, bundle: .none)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public let scanBoxingLayer: DesignConfig.BoxLayer
  public let scanEditLayer: DesignConfig.EditPointLayer
  public let onCaptureCompletion: () -> Void

  public override func viewDidLoad() {
    super.viewDidLoad()
    applyLayout()
    cameraView.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    cameraView.viewDidLayoutSubviews()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    cameraView.viewWillAppear(animated)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cameraView.viewWillDisappear(animated)
  }

  // MARK: Internal

  var isCaptured: Bool = false {
    didSet {
      guard isCaptured else { return }
      cameraView.capture()
      onCaptureCompletion()
    }
  }

  weak var cameraDelegate: CameraScanViewOutputDelegate? {
    didSet {
      cameraView.delegate = cameraDelegate
    }
  }

  // MARK: Private

  private lazy var cameraView: ScanCameraView = {
    let view = ScanCameraView(scanBoxingLayer: scanBoxingLayer, scanEditLayer: scanEditLayer)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}

extension CameraScanViewController {
  func applyLayout() {
    view.addSubview(cameraView)

    NSLayoutConstraint.activate([
      cameraView.topAnchor.constraint(equalTo: view.topAnchor),
      cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}
