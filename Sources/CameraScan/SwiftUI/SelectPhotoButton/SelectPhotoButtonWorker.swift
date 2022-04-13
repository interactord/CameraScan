import Combine
import Foundation
import Photos
import UIKit

struct SelectPhotoButtonWorker {

  // MARK: Internal

  var getLastImage: () -> AnyPublisher<UIImage?, Never> {
    {
      Future<UIImage?, Never> { promise in
        let manager = PHImageManager.default()
        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        guard result.count > 0 else { return promise(.success(.none)) }
        let asset = result.object(at: .zero)
        let size = CGSize(width: 300, height: 300)
        manager.requestImage(
          for: asset,
          targetSize: size,
          contentMode: .aspectFit,
          options: requestOptions)
        { image, _ in
          promise(.success(image))
        }
      }
      .eraseToAnyPublisher()
    }
  }

  // MARK: Private

  private struct Const {
    static let sortKey = "creationDate"
  }

  private let requestOptions: PHImageRequestOptions = {
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .fastFormat
    return options
  }()

  private let fetchOptions: PHFetchOptions = {
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: Const.sortKey, ascending: false)]

    options.fetchLimit = 1
    return options
  }()

}
