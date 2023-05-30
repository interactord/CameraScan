import Foundation
import SwiftUI
import UIKit

// MARK: - ImagePicker

public struct ImagePicker {
  private let allowsEditing: Bool
  private let sourceType: UIImagePickerController.SourceType
  private let onSelectedImageAction: (UIImage) -> Void
  private let onDismissalAction: () -> Void

  public init(
    allowsEditing: Bool = false,
    sourceType: UIImagePickerController.SourceType = .photoLibrary,
    onSelectedImageAction: @escaping (UIImage) -> Void,
    onDismissalAction: @escaping () -> Void = {})
  {
    self.allowsEditing = allowsEditing
    self.sourceType = sourceType
    self.onSelectedImageAction = onSelectedImageAction
    self.onDismissalAction = onDismissalAction
  }
}


// MARK: UIViewControllerRepresentable

extension ImagePicker: UIViewControllerRepresentable {

  public func makeUIViewController(context: Context) -> some UIViewController {
    let controller = UIImagePickerController()
    controller.allowsEditing = allowsEditing
    controller.sourceType = sourceType
    controller.delegate = context.coordinator

    return controller
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(
      onSelectedImageAction: onSelectedImageAction, onDismissalAction: onDismissalAction)
  }
}

extension ImagePicker {

  public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Lifecycle

    init(onSelectedImageAction: @escaping (UIImage) -> Void, onDismissalAction: @escaping () -> Void) {
      self.onSelectedImageAction = onSelectedImageAction
      self.onDismissalAction = onDismissalAction
    }

    // MARK: Public

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      onDismissalAction()
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
        onSelectedImageAction(image)
      }
      onDismissalAction()
    }

    // MARK: Private

    private let onSelectedImageAction: (UIImage) -> Void
    private let onDismissalAction: () -> Void

  }
}


