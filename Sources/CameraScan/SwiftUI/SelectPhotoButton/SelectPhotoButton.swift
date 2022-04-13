import Foundation
import SwiftUI

// MARK: - SelectPhotoButton

public struct SelectPhotoButton<PlaceHolder: View, Content: View> {
  private let placeholder: PlaceHolder
  private let onLoadedImage: (UIImage) -> Content

  @ObservedObject var intent: SelectPhotoButtonIntent

  public init(
    intent: SelectPhotoButtonIntent,
    @ViewBuilder placeholder: () -> PlaceHolder,
    onLoadedImage: @escaping (UIImage) -> Content)
  {
    self.intent = intent
    self.placeholder = placeholder()
    self.onLoadedImage = onLoadedImage
  }
}

// MARK: View

extension SelectPhotoButton: View {

  public var body: some View {
    Group {
      if let image = intent.lastImage {
        onLoadedImage(image)
      } else {
        placeholder
      }
    }
    .onAppear {
      intent.send(action: .getLastImage)
    }
  }
}
