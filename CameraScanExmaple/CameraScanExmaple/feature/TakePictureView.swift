import CameraScan
import SwiftUI

// MARK: - TakePictureView

struct TakePictureView: View {

  // MARK: Internal

  let router: RootRouter

  var body: some View {
    ZStack {
      CameraScanView(
        captured: $isCaptured,
        didCompletion: { image, model in
          router.navigatedTo(type: .edit(image: image, model: model, isRotateImage: true))
        }, didError: {
          print($0.localizedDescription)
        })

      VStack {
        Spacer()

        VStack {
          HStack {
            if
              let onImage = UIImage(systemName: "bolt.fill"),
              let offImage = UIImage(systemName: "bolt.slash.fill") {
              CameraTorchView(onImage: onImage, offImage: offImage)
            }

            Spacer()
            Button(action: { isCaptured.toggle() }) {
              Circle()
                .fill(Color.red)
                .frame(width: 60, height: 60, alignment: .center)
            }
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? .zero)
            .padding(.top, 20)
            Spacer()
          }
        }
        .background(Color.black.opacity(0.5))
      }
    }
    .ignoresSafeArea()
  }

  // MARK: Private

  @State private var isCaptured: Bool = false

}

// MARK: - TakePictureView_Previews

struct TakePictureView_Previews: PreviewProvider {
  static var previews: some View {
    TakePictureView(router: RootRouter.shared)
  }
}
