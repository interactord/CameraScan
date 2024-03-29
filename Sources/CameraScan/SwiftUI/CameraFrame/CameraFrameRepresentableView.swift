import AVFoundation
import Foundation
import SwiftUI

// MARK: - CameraFrameRepresentableView

struct CameraFrameRepresentableView {

  private let didCompletedAction: (UIImage) -> Void
  private let onDismissalAction: () -> Void

  @Binding var onTapCapture: Bool

  init(
    onTapCapture: Binding<Bool>,
    didCompletedAction: @escaping (UIImage) -> Void,
    onDismissalAction: @escaping () -> Void)
  {
    _onTapCapture = onTapCapture
    self.didCompletedAction = didCompletedAction
    self.onDismissalAction = onDismissalAction
  }
}

// MARK: UIViewControllerRepresentable

extension CameraFrameRepresentableView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> CameraFrameViewController {
    let controller = CameraFrameViewController()
    controller.proxyDelegate = context.coordinator
    return controller
  }

  func makeCoordinator() -> Coordinator {
    .init(parent: self, didCompletedAction: didCompletedAction, onDismissalAction: onDismissalAction)
  }

  func updateUIViewController(_ uiViewController: CameraFrameViewController, context: Context) {
    guard onTapCapture else { return }
    uiViewController.onTapRecord()
  }


}

extension CameraFrameRepresentableView {

  final class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    // MARK: Lifecycle

    init(parent: CameraFrameRepresentableView, didCompletedAction: @escaping (UIImage) -> Void, onDismissalAction: @escaping () -> Void) {
      self.parent = parent
      self.didCompletedAction = didCompletedAction
      self.onDismissalAction = onDismissalAction
    }

    // MARK: Internal

    let parent: CameraFrameRepresentableView

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      parent.onTapCapture = false

      if let cgImage = photo.cgImageRepresentation() {
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.getUIImageOrientationFromDevice)
        didCompletedAction(image)
      }
      onDismissalAction()
    }


    // MARK: Private

    private let didCompletedAction: (UIImage) -> Void
    private let onDismissalAction: () -> Void
  }
}


extension UIDeviceOrientation {
  fileprivate var getUIImageOrientationFromDevice: UIImage.Orientation {
    return switch self {
    case .portrait, .faceUp: .right
    case .portraitUpsideDown, .faceDown: .left
    case .landscapeLeft: .up
    case .landscapeRight: .down
    case .unknown: .up
    @unknown default: .up
    }
  }
}
