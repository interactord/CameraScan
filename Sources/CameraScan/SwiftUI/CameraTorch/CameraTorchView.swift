import Foundation
import SwiftUI

// MARK: - CameraTorchView

public struct CameraTorchView<OnContent: View, OffContent: View> {
  let onContent: OnContent
  let offContent: OffContent

  @StateObject private var intent: CameraTorchIntent = .init()

  private var state: CameraTorchModel.State { intent.state }

  public init(@ViewBuilder onContent: @escaping () -> OnContent, offContent: @escaping () -> OffContent) {
    self.onContent = onContent()
    self.offContent = offContent()
  }
}

// MARK: View

extension CameraTorchView: View {

  public var body: some View {
    Button(action: {
      intent.send(action: .onChangedTorchState)
    }, label: {
      if state.isTorchOn { onContent }
      else { offContent }
    })
    .onAppear { intent.send(action: .getCurrentTorchState) }
  }

}
