import AVFoundation
import UIKit

final class CameraFrameViewController: UIViewController {

  // MARK: Internal

  var image: UIImage?
  let session: AVCaptureSession = .init()
  var configuration: CameraFrameConfiguration = .default
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

  func mutateCameraPosition(isFront: Bool) {
    self.configuration.captureSession.stopRunning()
    self.configuration = isFront ? .frontCamera : .default
    applyVideoLayer()
    executeRunningSession()
  }

  // MARK: Fileprivate

  fileprivate func applyVideoLayer() {
    guard let layer = configuration.previewLayer else { return }
    layer.frame = view.frame

    guard let oldLayer = view.layer.sublayers?.first else {
      view.layer.insertSublayer(layer, at: .zero)
      return
    }

    view.layer.replaceSublayer(oldLayer, with: layer)
  }

  fileprivate func executeRunningSession() {
    #if targetEnvironment(simulator)
    #else
    DispatchQueue.global(qos: .background).async { [weak self] in
      self?.configuration.captureSession.startRunning()
    }
    #endif
  }

}


