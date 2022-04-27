import CameraScan
import SwiftUI

// MARK: - EditPictureView

struct EditPictureView: View {

  // MARK: Internal

  let image: UIImage
  let quad: Quadrilateral?
  let isRotateImage: Bool
  let router: RootRouter

  var body: some View {
    VStack {
      CameraScanImageEditView(
        completed: $isCompleted,
        image: image,
        quad: quad,
        scanBoxingLayer: .defaultValue(),
        scanEditLayer: .defaultValue(),
        isRotateImage: isRotateImage,
        didCroppedImage: { router.navigatedTo(type: .flatImage(image: $0)) },
        errorAction: { error in
          print(error.errorDescription ?? "")
        })
      Button(action: {
        isCompleted.toggle()
      }) {
        Text("Done")
      }
    }
  }

  // MARK: Private

  @State private var isCompleted: Bool = false
}

// MARK: - EditPictureView_Previews

struct EditPictureView_Previews: PreviewProvider {
  static var previews: some View {
    EditPictureView(image: .init(), quad: .none, isRotateImage: false, router: RootRouter.shared)
  }
}
