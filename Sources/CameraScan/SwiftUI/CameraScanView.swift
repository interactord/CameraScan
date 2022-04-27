import SwiftUI
import UIKit

// MARK: - CameraScanView

public struct CameraScanView {
  public init(
    onTapCapture: Binding<Bool>,
    scanBoxingLayer: DesignConfig.BoxLayer = .defaultValue(),
    scanEditLayer: DesignConfig.EditPointLayer = .defaultValue(),
    didCompletion: @escaping (UIImage, Quadrilateral?) -> Void,
    didError: @escaping (CameraScanError) -> Void)
  {
    self.onTapCapture = onTapCapture
    self.scanBoxingLayer = scanBoxingLayer
    self.scanEditLayer = scanEditLayer
    self.didCompletion = didCompletion
    self.didError = didError
  }

  private let didCompletion: (UIImage, Quadrilateral?) -> Void
  private let didError: (CameraScanError) -> Void
  private let onTapCapture: Binding<Bool>
  private let scanBoxingLayer: DesignConfig.BoxLayer
  private let scanEditLayer: DesignConfig.EditPointLayer
}

// MARK: UIViewControllerRepresentable

extension CameraScanView: UIViewControllerRepresentable {

  public func makeCoordinator() -> Coordinator {
    Coordinator(isCapture: onTapCapture, didCompletion: didCompletion, didError: didError)
  }

  public func makeUIViewController(context: Context) -> CameraScanViewController {
    let controller = CameraScanViewController(
      scanBoxingLayer: scanBoxingLayer,
      scanEditLayer: scanEditLayer,
      onCaptureCompletion: {
      onTapCapture.wrappedValue = false
    })
    controller.cameraDelegate = context.coordinator
    return controller
  }

  public func updateUIViewController(_ uiViewController: CameraScanViewController, context: Context) {
    uiViewController.isCaptured = onTapCapture.wrappedValue
  }

}

extension CameraScanView {
  public class Coordinator: CameraScanViewOutputDelegate {

    // MARK: Lifecycle

    public init(
      isCapture: Binding<Bool>,
      didCompletion: @escaping (UIImage, Quadrilateral?) -> Void,
      didError: @escaping (CameraScanError) -> Void)
    {
      self.isCapture = isCapture
      self.didCompletion = didCompletion
      self.didError = didError
    }

    // MARK: Public

    public func captureImage(result: Result<(UIImage, Quadrilateral?), CameraScanError>) {
      isCapture.wrappedValue = false

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
    let isCapture: Binding<Bool>

  }
}
