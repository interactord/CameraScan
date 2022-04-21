import Foundation
import SwiftUI

// MARK: - CameraGridLineView

public struct CameraGridLineView {

  let horizontalLine: Int
  let verticalLine: Int
  let color: Color
  let lineWidth: CGFloat

  public init(
    horizontalLine: Int,
    verticalLine: Int,
    color: Color,
    lineWidth: CGFloat)
  {
    self.horizontalLine = horizontalLine
    self.verticalLine = verticalLine
    self.color = color
    self.lineWidth = lineWidth
  }

}

// MARK: View

extension CameraGridLineView: View {

  public var body: some View {
    GeometryReader { reader in
      Path { path in
        let numberOfVGridLines = Int(reader.size.height) / verticalLine
        let numberOfHGridLines = Int(reader.size.width) / horizontalLine

        (1...(horizontalLine - 1)).forEach { element in
          let vOffset: CGFloat = CGFloat(element) * CGFloat(numberOfHGridLines)
          path.move(to: .init(x: vOffset, y: .zero))
          path.addLine(to: .init(x: vOffset, y: reader.size.height))
        }

        (1...(verticalLine - 1)).forEach { element in
          let hOffset: CGFloat = CGFloat(element) * CGFloat(numberOfVGridLines)
          path.move(to: .init(x: .zero, y: hOffset))
          path.addLine(to: .init(x: reader.size.width, y: hOffset))
        }
      }
      .stroke(color, lineWidth: lineWidth)
    }
  }

}
