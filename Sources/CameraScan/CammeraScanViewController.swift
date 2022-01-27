import Combine
import SwiftUI
import UIKit

// MARK: - CameraScanViewController

public final class CameraScanViewController: UIViewController {

  // MARK: Public

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
      isCaptured = false
    }
  }

  weak var cameraDelegate: CameraScanViewOutputDelegate? {
    didSet {
      cameraView.delegate = cameraDelegate
    }
  }

  // MARK: Private

  private let cameraView: ScanCameraView = {
    let view = ScanCameraView()
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
