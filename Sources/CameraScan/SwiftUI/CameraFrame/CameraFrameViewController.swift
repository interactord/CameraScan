import AVFoundation
import UIKit

final class CameraFrameViewController: UIViewController {

  // MARK: Internal

  var image: UIImage?
  let session: AVCaptureSession = .init()
  let configuration: CameraFrameConfiguration = .default
  weak var proxyDelegate: AVCapturePhotoCaptureDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    applyVideoLayer()
    executeRunningSession()
  }

  func onTapRecord() {
    guard let proxyDelegate = proxyDelegate else { return }
    configuration.photoOutput?.capturePhoto(
      with: .init(),
      delegate: proxyDelegate)
  }

  // MARK: Fileprivate

  fileprivate func applyVideoLayer() {
    if let layer = configuration.previewLayer {
      layer.frame = view.frame
      view.layer.insertSublayer(layer, at: .zero)
    }
  }

  fileprivate func executeRunningSession() {
    #if targetEnvironment(simulator)
    #else
    DispatchQueue.main.async { [weak self] in
      self?.configuration.captureSession.startRunning()
    }
    #endif
  }

}


