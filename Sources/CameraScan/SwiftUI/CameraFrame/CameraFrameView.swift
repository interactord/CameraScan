import SwiftUI

// MARK: - CameraFrameView

public struct CameraFrameView {

  @Binding private var onTapCapture: Bool
  @Binding private var isFrontCamera: Bool
  private let didTapCaptureAction: (UIImage) -> Void
  private let onDismissalAction: () -> Void

  public init(
    onTapCapture: Binding<Bool>,
    isFrontCamera: Binding<Bool>,
    didTapCaptureAction: @escaping (UIImage) -> Void,
    onDismissalAction: @escaping () -> Void = {})
  {
    _onTapCapture = onTapCapture
    _isFrontCamera = isFrontCamera
    self.didTapCaptureAction = didTapCaptureAction
    self.onDismissalAction = onDismissalAction
  }
}

// MARK: View

extension CameraFrameView: View {

  public var body: some View {
    CameraFrameRepresentableView(
      onTapCapture: $onTapCapture,
      isFrontCamera: $isFrontCamera,
      didCompletedAction: didTapCaptureAction,
      onDismissalAction: onDismissalAction)
  }

}
