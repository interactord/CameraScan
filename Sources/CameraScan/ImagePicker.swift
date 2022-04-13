import Foundation
import UIKit
import SwiftUI

struct ImagePicker {
  @Environment(\.presentationMode) var presentationMode

  let onSelectedImageAction: (UIImage) -> Void

  init(onSelectedImageAction: @escaping (UIImage) -> Void) {
    self.onSelectedImageAction = onSelectedImageAction
  }

}


extension ImagePicker: UIViewControllerRepresentable {

  func makeUIViewController(context: Context) -> some UIViewController {
    let controller = UIImagePickerController()
    controller.allowsEditing = false
    controller.sourceType = .photoLibrary
    controller.delegate = context.coordinator

    return controller
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(
      parent: self,
      onSelectedImageAction: onSelectedImageAction)
  }
}

extension ImagePicker {

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePicker
    let onSelectedImageAction: (UIImage) -> Void

    init(parent: ImagePicker, onSelectedImageAction: @escaping (UIImage) -> Void) {
      self.parent = parent
      self.onSelectedImageAction = onSelectedImageAction
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let image = info[.originalImage] as? UIImage {
        onSelectedImageAction(image)
      }

      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}


