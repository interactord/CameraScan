import CameraScan
import SwiftUI

// MARK: - TakePictureView

struct TakePictureView: View {

  // MARK: Internal

  let router: RootRouter

  var body: some View {
    ZStack {
      CameraFrameView(
        onTapCapture: $isCaptured,
        didTapCaptureAction: { print($0) })
        .background(Color.black)

      CameraGridLineView(
        horizontalLine: 4,
        verticalLine: 6,
        color: .white,
        lineWidth: 1)
        .opacity(0.23)


      VStack {
        Spacer()
        VStack {
          HStack {
            Spacer()
            SelectPhotoButton(onSelectedImageAction: { image in
              print(image)
            }, content: {
              if let image = UIImage(systemName: "photo.artframe") {
                Image(uiImage: image)
              } else {
                EmptyView()
              }
            })

            Spacer(minLength: 15)
            Button(action: { isCaptured.toggle() }) {
              Circle()
                .fill(Color.red)
                .frame(width: 60, height: 60, alignment: .center)
            }
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? .zero)
            .padding(.top, 20)

            Spacer(minLength: 15)

            if
              let onImage = UIImage(systemName: "bolt.fill"),
              let offImage = UIImage(systemName: "bolt.slash.fill")
            {
              CameraTorchView(
                onContent: { Image(uiImage: onImage) },
                offContent: { Image(uiImage: offImage) })
            }

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
