import Foundation
import SwiftUI

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
