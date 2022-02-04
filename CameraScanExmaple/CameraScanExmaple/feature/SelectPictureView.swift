import SwiftUI
import UIKit

// MARK: - SelectPictureView

struct SelectPictureView: UIViewControllerRepresentable {

  let didSelectAction: (UIImage) -> Void
  @Environment(\.presentationMode) private var presentationMode

  func makeCoordinator() -> Coordinator {
    .init(self)
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

}

extension SelectPictureView {

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Lifecycle

    init(_ parent: SelectPictureView) {
      self.parent = parent
    }

    // MARK: Internal

    var parent: SelectPictureView

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      if let image = info[.originalImage] as? UIImage {
        parent.didSelectAction(image)
      }

      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}
