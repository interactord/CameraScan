import Foundation

enum CameraTorchModel {
  struct State {
    var isTorchOn: Bool = false
  }

  enum ViewAction {
    case getCurrentTorchState
    case onChangedTorchState
  }
}
