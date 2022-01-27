import CameraScan
import SwiftUI

// MARK: - EditPictureView

struct EditPictureView: View {

  let image: UIImage
  let quad: Quadrilateral?

  var body: some View {
    VStack {
      CameraScanImageEditView(completed: $isCompleted, image: image, quad: quad) {
        print($0)
      }
      Button(action: {
        isCompleted.toggle()
      }) {
        Text("Done")
      }
    }
  }

  @State private var isCompleted: Bool = false
}

// MARK: - EditPictureView_Previews

struct EditPictureView_Previews: PreviewProvider {
  static var previews: some View {
    EditPictureView(image: .init(), quad: .none)
  }
}
