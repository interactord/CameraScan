import Combine
import Foundation
import UIKit

// MARK: - SelectPhotoButtonIntent

public final class SelectPhotoButtonIntent: ObservableObject {

  // MARK: Lifecycle

  public init(onPermissionErrorAction: @escaping () -> Void) {
    self.onPermissionErrorAction = onPermissionErrorAction
  }

  // MARK: Internal

  @Published var lastImage: UIImage?

  func send(action: SelectPhotoButtonModel.ViewAction) {
    switch action {
    case .getLastImage:
      break

    case .fetchImage:
      worker
        .getLastImage()
        .receive(on: RunLoop.main)
        .sink(receiveValue: { [weak self] in
          guard let self = self else { return }
          self.lastImage = $0
        })
        .store(in: &cancelables)
    }
  }

  // MARK: Private

  private var cancelables: Set<AnyCancellable> = []
  private let worker: SelectPhotoButtonWorker = .init()
  private let onPermissionErrorAction: () -> Void

}


// MARK: - SelectPhotoButtonModel

enum SelectPhotoButtonModel {
  struct State {
    var imageData: Data?
  }

  enum ViewAction {
    case getLastImage
    case fetchImage
  }
}
