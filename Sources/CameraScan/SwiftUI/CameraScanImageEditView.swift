import SwiftUI
import UIKit

// MARK: - CameraScanImageEditView

public struct CameraScanImageEditView {

  // MARK: Lifecycle

  public init(
    completed: Binding<Bool>,
    image: UIImage,
    quad: Quadrilateral?,
    scanBoxingLayer: DesignConfig.BoxLayer = .defaultValue(),
    scanEditLayer: DesignConfig.EditPointLayer = .defaultValue(),
    isRotateImage: Bool,
    didCropAction: @escaping (Quadrilateral?, UIImage) -> Void,
    errorAction: @escaping (CameraScanError) -> Void)
  {
    self.completed = completed
    self.image = image
    self.quad = quad
    self.scanBoxingLayer = scanBoxingLayer
    self.scanEditLayer = scanEditLayer
    self.isRotateImage = isRotateImage
    self.didCropAction = didCropAction
    self.errorAction = errorAction
  }

  // MARK: Private

  private let completed: Binding<Bool>
  private let image: UIImage
  private let quad: Quadrilateral?
  private let scanBoxingLayer: DesignConfig.BoxLayer
  private let scanEditLayer: DesignConfig.EditPointLayer
  private let isRotateImage: Bool
  private let didCropAction: (Quadrilateral?, UIImage) -> Void
  private let errorAction: (CameraScanError) -> Void

}

// MARK: UIViewControllerRepresentable

extension CameraScanImageEditView: UIViewControllerRepresentable {

  public func makeUIViewController(context: Context) -> EditImageViewController {
    let controller = EditImageViewController(
      image: image,
      quad: quad,
      scanBoxingLayer: scanBoxingLayer,
      scanEditLayer: scanEditLayer,
      isRotateImage: isRotateImage,
      errorAction: errorAction)
    controller.delegate = context.coordinator
    return controller
  }

  public func updateUIViewController(_ uiViewController: EditImageViewController, context: Context) {
    uiViewController.isCropped = completed.wrappedValue
  }

  public func makeCoordinator() -> Coordinator {
    .init(didCropAction: didCropAction)
  }
}

extension CameraScanImageEditView {
  public class Coordinator: EditImageViewDelegate {

    // MARK: Lifecycle

    init(didCropAction: @escaping (Quadrilateral?, UIImage) -> Void) {
      self.didCropAction = didCropAction
    }

    // MARK: Public

    public func cropped(quard: Quadrilateral?, image: UIImage) {
      didCropAction(quard, image)
    }

    // MARK: Internal

    let didCropAction: (Quadrilateral?, UIImage) -> Void

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
      didCropAction: { _, _ in },
      errorAction: { _ in })
  }
}
