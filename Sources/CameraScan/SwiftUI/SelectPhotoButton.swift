import Foundation
import SwiftUI

// MARK: - SelectPhotoButton

public struct SelectPhotoButton<Content: View> {

  private let content: Content
  private let onSelectedImageAction: (UIImage) -> Void
  @State private var isShowImagePicker: Bool = false

  public init(
    onSelectedImageAction: @escaping (UIImage) -> Void,
    @ViewBuilder content: () -> Content)
  {
    self.onSelectedImageAction = onSelectedImageAction
    self.content = content()
  }
}

// MARK: View

extension SelectPhotoButton: View {

  public var body: some View {
    Button(action: {
      isShowImagePicker = true
    }, label: {
      content
    })
    .fullScreenCover(
      isPresented: $isShowImagePicker,
      content: {
        ImagePicker(
          onSelectedImageAction: onSelectedImageAction,
          onDismissalAction: { isShowImagePicker = false })
      })
  }
}
