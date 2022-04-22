import SwiftUI

// MARK: - CameraFrameView

public struct CameraFrameView {

  @Binding private var onTapCapture: Bool
  private let didTapCaptureAction: (UIImage) -> Void
  private let onDismissalAction: () -> Void

  public init(
    onTapCapture: Binding<Bool>,
    didTapCaptureAction: @escaping (UIImage) -> Void,
    onDismissalAction: @escaping () -> Void = {})
  {
    _onTapCapture = onTapCapture
    self.didTapCaptureAction = didTapCaptureAction
    self.onDismissalAction = onDismissalAction
  }
}

// MARK: View

extension CameraFrameView: View {

  public var body: some View {
    CameraFrameRepresentableView(
      onTapCapture: $onTapCapture,
      didCompletedAction: didTapCaptureAction,
      onDismissalAction: onDismissalAction)
  }

}
