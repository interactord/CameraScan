import Foundation
import SwiftUI

// MARK: - SelectPhotoButton

public struct SelectPhotoButton<Content: View> {

  private let content: Content
  private let onSelectedImageAction: (UIImage) -> Void
  @State private var isShowImagePicker: Bool = false

  private let allowsEditing: Bool
  private let sourceType: UIImagePickerController.SourceType

  public init(
    allowsEditing: Bool = false,
    sourceType: UIImagePickerController.SourceType = .photoLibrary,
    onSelectedImageAction: @escaping (UIImage) -> Void,
    @ViewBuilder content: () -> Content)
  {
    self.allowsEditing = allowsEditing
    self.sourceType = sourceType
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
          allowsEditing: allowsEditing,
          sourceType: sourceType,
          onSelectedImageAction: onSelectedImageAction,
          onDismissalAction: { isShowImagePicker = false })
      })
  }
}
