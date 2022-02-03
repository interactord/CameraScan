import SwiftUI

struct FlatImageView: View {

  let image: UIImage

  var body: some View {
    VStack {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: .zero, maxWidth: .infinity)
    }
  }
}
