import SwiftUI

// MARK: - CameraFrameView

public struct CameraFrameView {

  @Binding var onTapCapture: Bool
  let didTapCaptureAction: (UIImage) -> Void

  public init(
    onTapCapture: Binding<Bool>,
    didTapCaptureAction: @escaping (UIImage) -> Void)
  {
    _onTapCapture = onTapCapture
    self.didTapCaptureAction = didTapCaptureAction
  }
}

// MARK: View

extension CameraFrameView: View {

  public var body: some View {
    CameraFrameRepresentableView(
      onTapCapture: $onTapCapture,
      didCompletedAction: didTapCaptureAction)
  }

}
