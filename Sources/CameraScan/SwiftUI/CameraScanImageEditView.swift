import SwiftUI
import UIKit

// MARK: - CameraScanImageEditView

public struct CameraScanImageEditView {

  // MARK: Lifecycle

  public init(
    completed: Binding<Bool>,
    image: UIImage,
    quad: Quadrilateral?,
    strokeColor: UIColor? = .none,
    isRotateImage: Bool,
    didCroppedImage: @escaping (UIImage) -> Void)
  {
    self.completed = completed
    self.image = image
    self.quad = quad
    self.strokeColor = strokeColor
    self.isRotateImage = isRotateImage
    self.didCroppedImage = didCroppedImage
  }

  // MARK: Private

  private let completed: Binding<Bool>
  private let image: UIImage
  private let quad: Quadrilateral?
  private let strokeColor: UIColor?
  private let isRotateImage: Bool
  private let didCroppedImage: (UIImage) -> Void

}

// MARK: UIViewControllerRepresentable

extension CameraScanImageEditView: UIViewControllerRepresentable {

  public func makeUIViewController(context: Context) -> EditImageViewController {
    let controller = EditImageViewController(
      image: image,
      quad: quad,
      isRotateImage: isRotateImage)
    controller.delegate = context.coordinator
    return controller
  }

  public func updateUIViewController(_ uiViewController: EditImageViewController, context: Context) {
    uiViewController.isCropped = completed.wrappedValue
  }

  public func makeCoordinator() -> Coordinator {
    .init(didCroppedImage: didCroppedImage)
  }
}

extension CameraScanImageEditView {
  public class Coordinator: EditImageViewDelegate {

    // MARK: Lifecycle

    init(didCroppedImage: @escaping (UIImage) -> Void) {
      self.didCroppedImage = didCroppedImage
    }

    // MARK: Public

    public func cropped(image: UIImage) {
      didCroppedImage(image)
    }

    // MARK: Internal

    let didCroppedImage: (UIImage) -> Void

  }
}

// MARK: - CameraScanEditView_Previews

struct CameraScanEditView_Previews: PreviewProvider {
  static var previews: some View {
    CameraScanImageEditView(
      completed: .constant(false),
      image: .init(),
      quad: .none,
      isRotateImage: false,
      didCroppedImage: { _ in })
  }
}
