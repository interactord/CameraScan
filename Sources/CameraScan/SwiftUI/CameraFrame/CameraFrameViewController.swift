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
    excuteRunningSession()
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

  fileprivate func excuteRunningSession() {
    #if targetEnvironment(simulator)
    #else
    configuration.captureSession.startRunning()
    #endif
  }

}


