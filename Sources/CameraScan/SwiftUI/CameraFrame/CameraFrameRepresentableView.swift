import AVFoundation
import Foundation
import SwiftUI

// MARK: - CameraFrameRepresentableView

struct CameraFrameRepresentableView {

  @Environment(\.presentationMode) var presentationMode

  let didCompletedAction: (UIImage) -> Void
  @Binding var onTapCapture: Bool

  init(
    onTapCapture: Binding<Bool>,
    didCompletedAction: @escaping (UIImage) -> Void)
  {
    _onTapCapture = onTapCapture
    self.didCompletedAction = didCompletedAction
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
    .init(parent: self, didCompletedAction: didCompletedAction)
  }

  func updateUIViewController(_ uiViewController: CameraFrameViewController, context: Context) {
    guard onTapCapture else { return }
    uiViewController.onTapRecord()
  }


}

extension CameraFrameRepresentableView {

  final class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    // MARK: Lifecycle

    init(parent: CameraFrameRepresentableView, didCompletedAction: @escaping (UIImage) -> Void) {
      self.parent = parent
      self.didCompletedAction = didCompletedAction
    }

    // MARK: Internal

    let parent: CameraFrameRepresentableView
    let didCompletedAction: (UIImage) -> Void

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
      parent.onTapCapture = false

      if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
        didCompletedAction(image)
      }
      parent.presentationMode.wrappedValue.dismiss()
    }
  }

}
