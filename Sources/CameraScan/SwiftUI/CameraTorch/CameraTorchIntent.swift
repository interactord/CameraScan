import Combine
import Foundation

final class CameraTorchIntent: ObservableObject {

  // MARK: Internal

  @Published var state: CameraTorchModel.State = .init(isTorchOn: false)

  let worker: CameraTorchWorker = .init()

  func send(action: CameraTorchModel.ViewAction) {
    switch action {
    case .getCurrentTorchState:
      worker
        .currentTorchOn()
        .sink(receiveValue: { [weak self] in
          guard let self = self else { return }
          self.state.isTorchOn = $0
        })
        .store(in: &cancelables)

    case .onChangedTorchState:
      worker
        .onChangedTorchMode(state.isTorchOn)
        .sink(receiveValue: { [weak self] in
          guard let self = self else { return }
          self.state.isTorchOn = $0
        })
        .store(in: &cancelables)
    }
  }

  // MARK: Private

  private var cancelables: Set<AnyCancellable> = []
}


