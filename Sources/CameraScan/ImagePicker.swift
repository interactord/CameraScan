import Foundation
import SwiftUI
import UIKit

// MARK: - ImagePicker

public struct ImagePicker {
  @Environment(\.presentationMode) var presentationMode

  private let onSelectedImageAction: (UIImage) -> Void

  public init(onSelectedImageAction: @escaping (UIImage) -> Void) {
    self.onSelectedImageAction = onSelectedImageAction
  }

}


// MARK: UIViewControllerRepresentable

extension ImagePicker: UIViewControllerRepresentable {

  public func makeUIViewController(context: Context) -> some UIViewController {
    let controller = UIImagePickerController()
    controller.allowsEditing = false
    controller.sourceType = .photoLibrary
    controller.delegate = context.coordinator

    return controller
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      parent: self,
      onSelectedImageAction: onSelectedImageAction)
  }
}

extension ImagePicker {

  public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Lifecycle

    init(parent: ImagePicker, onSelectedImageAction: @escaping (UIImage) -> Void) {
      self.parent = parent
      self.onSelectedImageAction = onSelectedImageAction
    }

    // MARK: Internal

    var parent: ImagePicker
    let onSelectedImageAction: (UIImage) -> Void

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.presentationMode.wrappedValue.dismiss()
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let image = info[.originalImage] as? UIImage {
        onSelectedImageAction(image)
      }

      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}


