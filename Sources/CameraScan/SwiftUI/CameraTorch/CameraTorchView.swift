import Foundation
import SwiftUI

// MARK: - CameraTorchView

public struct CameraTorchView {
  let onImage: UIImage
  let offImage: UIImage

  @StateObject private var intent: CameraTorchIntent = .init()

  private var state: CameraTorchModel.State { intent.state }

  public init(onImage: UIImage, offImage: UIImage) {
    self.onImage = onImage
    self.offImage = offImage
  }
}

// MARK: View

extension CameraTorchView: View {

  public var body: some View {
    Button(action: {
      intent.send(action: .onChangedTorchState)
    }, label: {
      Image(uiImage: state.isTorchOn ? onImage : offImage)
    })
    .onAppear { intent.send(action: .getCurrentTorchState) }
  }

}
