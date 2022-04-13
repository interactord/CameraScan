import CameraScan
import SwiftUI

// MARK: - TakePictureForEdgeDetectingView

struct TakePictureForEdgeDetectingView: View {

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

      CameraGridLineView(horizontalLine: 4, verticalLine: 6, color: .white, lineWidth: 1)

      VStack {
        Spacer()

        VStack {
          HStack {
            Spacer()
            Button(action: {
              print("엘범 불러오기")
            }, label: {
              SelectPhotoButton(
                intent: SelectPhotoButtonIntent(onPermissionErrorAction: {}),
                placeholder: {
                  Text("")
                    .background(Color.red)
                    .frame(width: 80, height: 80)
                }) { image in
                  Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
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
              CameraTorchView(onImage: onImage, offImage: offImage)
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

// MARK: - TakePictureForEdgeDetectingView_Previews

struct TakePictureForEdgeDetectingView_Previews: PreviewProvider {
  static var previews: some View {
    TakePictureView(router: RootRouter.shared)
  }
}
