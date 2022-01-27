import SwiftUI
import UIKit

// MARK: - CameraScanView

public struct CameraScanView {
  public init(
    captured: Binding<Bool>,
    didCompletion: @escaping (UIImage, Quadrilateral?) -> Void,
    didError: @escaping (CameraScanError) -> Void)
  {
    self.captured = captured
    self.didCompletion = didCompletion
    self.didError = didError
  }

  let didCompletion: (UIImage, Quadrilateral?) -> Void
  let didError: (CameraScanError) -> Void
  let captured: Binding<Bool>
}

// MARK: UIViewControllerRepresentable

extension CameraScanView: UIViewControllerRepresentable {

  public func makeCoordinator() -> Coordinator {
    Coordinator(didCompletion: didCompletion, didError: didError)
  }

  public func makeUIViewController(context: Context) -> CameraScanViewController {
    let controller = CameraScanViewController(nibName: .none, bundle: .none)
    controller.cameraDelegate = context.coordinator
    return controller
  }

  public func updateUIViewController(_ uiViewController: CameraScanViewController, context: Context) {
    uiViewController.isCaptured = captured.wrappedValue
  }

}

extension CameraScanView {
  public class Coordinator: CameraScanViewOutputDelegate {

    // MARK: Lifecycle

    public init(
      didCompletion: @escaping (UIImage, Quadrilateral?) -> Void,
      didError: @escaping (CameraScanError) -> Void)
    {
      self.didCompletion = didCompletion
      self.didError = didError
    }

    // MARK: Public

    public func captureImage(result: Result<(UIImage, Quadrilateral?), CameraScanError>) {
      switch result {
      case let .success((image, quad)):
        didCompletion(image, quad)
      case let .failure(error):
        didError(error)
      }
    }

    // MARK: Internal

    let didCompletion: (UIImage, Quadrilateral?) -> Void
    let didError: (CameraScanError) -> Void

  }
}
