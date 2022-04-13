import AVFoundation
import Combine
import Foundation

struct CameraTorchWorker {
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
