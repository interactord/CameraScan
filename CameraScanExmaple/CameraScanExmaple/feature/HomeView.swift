import CameraScan
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  let router: RootRouter

  @State var isShowSelectPictureView = false

  var body: some View {
    VStack {
      Text("Camera Scan")
      Spacer()
      Button(action: {
        isPresentedActionSheet.toggle()
      }) {
        Text("Select Scan")
      }
      .padding(.vertical, 30)
    }
    .actionSheet(isPresented: $isPresentedActionSheet) {
      ActionSheet(title: .init("Select Scan"), message: .none, buttons: [
        .default(.init("Take a picture"), action: {
          router.navigatedTo(type: .takeAPicture)
        }),
        .default(.init("Select a picture"), action: {
          isShowSelectPictureView.toggle()
        }),
        ActionSheet.Button.cancel(),
      ])
    }
    .sheet(isPresented: $isShowSelectPictureView) {
      SelectPictureView { image in
        ImageDetactionFunctor().detact(image: image) { model in
          router.navigatedTo(type: .edit(image: image, model: model, isRotateImage: false))
        }
      }
    }
  }

  // MARK: Private

  @State private var isPresentedActionSheet = false

}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(router: RootRouter.shared)
  }
}
