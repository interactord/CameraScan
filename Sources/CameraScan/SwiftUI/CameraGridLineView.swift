import Foundation
import SwiftUI

public struct CameraGridLineView {

  let horizontalSpacing: CGFloat
  let verticalSpacing: CGFloat
  let color: Color
  let lineWidth: CGFloat

  public init(
    horizontalSpacing: CGFloat,
    verticalSpacing: CGFloat,
    color: Color,
    lineWidth: CGFloat
  ) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.color = color
    self.lineWidth = lineWidth
  }

}

extension CameraGridLineView: View {

  public var body: some View {
    GeometryReader { reader in
      Path { path in
        let numberOfHGridLines = Int(reader.size.height / verticalSpacing)
        let numberOfVGridLines = Int(reader.size.width / horizontalSpacing)

        (0...numberOfVGridLines).enumerated().forEach { element in
          let vOffset: CGFloat = CGFloat(element.offset) * horizontalSpacing
          path.move(to: .init(x: vOffset, y: .zero))
          path.addLine(to: .init(x: vOffset, y: reader.size.height))
        }

        (0...numberOfHGridLines).enumerated().forEach { element in
          let hOffset: CGFloat = CGFloat(element.offset) * verticalSpacing
          path.move(to: .init(x: .zero, y: hOffset))
          path.addLine(to: .init(x: reader.size.width, y: hOffset))
        }
      }
      .stroke(color, lineWidth: lineWidth)
    }
  }

}
