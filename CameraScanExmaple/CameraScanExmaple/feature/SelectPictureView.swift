import SwiftUI
import UIKit

// MARK: - SelectPictureView

struct SelectPictureView: UIViewControllerRepresentable {

  // MARK: Lifecycle

  init(didSelectAction: @escaping (UIImage) -> Void, onDismissalAction: @escaping () -> Void = {}) {
    self.didSelectAction = didSelectAction
    self.onDismissalAction = onDismissalAction
  }

  // MARK: Internal

  func makeCoordinator() -> Coordinator {
    .init(didSelectAction: didSelectAction, onDismissalAction: onDismissalAction)
  }

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let controller = UIImagePickerController()
    controller.sourceType = .photoLibrary
    controller.allowsEditing = false
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
  }

  // MARK: Private

  private let didSelectAction: (UIImage) -> Void
  private let onDismissalAction: () -> Void

}

extension SelectPictureView {

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Lifecycle

    init(didSelectAction: @escaping (UIImage) -> Void, onDismissalAction: @escaping () -> Void) {
      self.didSelectAction = didSelectAction
      self.onDismissalAction = onDismissalAction
    }

    // MARK: Internal

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      onDismissalAction()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      if let image = info[.originalImage] as? UIImage {
        didSelectAction(image)
      }

      onDismissalAction()
    }

    // MARK: Private

    private let didSelectAction: (UIImage) -> Void
    private let onDismissalAction: () -> Void

  }
}
