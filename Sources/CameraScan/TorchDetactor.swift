import Foundation
import Combine
import AVFoundation

final class TorchIntent: ObservableObject {

  @Published var state: TorchModel.State = .init(isTorchOn: false)

  private var cancelables: Set<AnyCancellable> = []
  let useCase: TorchUseCase = .init()

  func send(action: TorchModel.ViewAction) {
    switch action {
    case .getCurrentTorchState:
      useCase
        .currentTorchOn()
        .sink(receiveValue: { [weak self] in
          guard let self = self else { return }
          self.state.isTorchOn = $0
        })
        .store(in: &cancelables)

    case .onChangedTorchState:
      useCase
        .onChangedTorchMode(state.isTorchOn)
        .sink(receiveValue: { [weak self] in
          guard let self = self else { return }
          self.state.isTorchOn = $0
        })
        .store(in: &cancelables)
    }
  }

}

struct TorchUseCase {

  var onChangedTorchMode: (Bool) -> AnyPublisher<Bool, Never> {
    { isOn in
      Future<Bool, Never> { promise in
        guard
          let device = AVCaptureDevice.default(for: .video),
          device.hasTorch
        else { return promise(.success(false)) }

        do {
          try device.lockForConfiguration(); defer { device.unlockForConfiguration() }
          device.torchMode = isOn ? .off : .on

          promise(.success(!isOn))
        } catch {
          return promise(.success(false))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  var currentTorchOn: () -> AnyPublisher<Bool, Never> {
    {
      Future<Bool, Never> { promise in
        guard
          let device = AVCaptureDevice.default(for: .video),
          device.hasTorch
        else { return promise(.success(false)) }

        do {
          try device.lockForConfiguration(); defer { device.unlockForConfiguration() }
          return promise(.success(device.isTorchActive))
        } catch {
          return promise(.success(false))
        }
      }
      .eraseToAnyPublisher()
    }

  }
}

enum TorchModel {
  struct State {
    var isTorchOn: Bool = false
  }

  enum ViewAction {
    case getCurrentTorchState
    case onChangedTorchState
  }
}
