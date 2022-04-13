import CameraScan
import SwiftUI

// MARK: - FlatImageView

struct FlatImageView: View {

  // MARK: Lifecycle

  init(image: UIImage) {
    self.image = image
  }

  // MARK: Internal

  @State private(set) var image: UIImage

  var body: some View {
    ZStack {
      VStack {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(minWidth: .zero, maxWidth: .infinity, alignment: .center)
      }
      VStack {
        Spacer()
        Button(action: {
          guard let image = ImageDetactionFunctor().rotate(image: self.image, angle: .init(value: 90, unit: .degrees)) else { return }
          self.image = image
        }) {
          Text("Ratate")
            .frame(minWidth: .zero, maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(Color.white)
        }
      }
    }
  }
}
