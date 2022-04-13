import UIKit
import AVFoundation

final class CameraFrameViewController: UIViewController {

  var image: UIImage?
  let session: AVCaptureSession = .init()
  let configuration: CameraFrameConfiguration = .default
  weak var proxyDelegate: AVCapturePhotoCaptureDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    applyVideoLayer()
    excuteRunningSession()
  }

  fileprivate func applyVideoLayer() {
    if let layer = configuration.previewLayer {
      layer.frame = view.frame
      view.layer.insertSublayer(layer, at: .zero)
    }
  }

  fileprivate func excuteRunningSession() {
    configuration.captureSession.startRunning()
  }

  func onTapRecord() {
    guard let proxyDelegate = proxyDelegate else { return }
    configuration.photoOutput?.capturePhoto(
      with: .init(),
      delegate: proxyDelegate)
  }
}


