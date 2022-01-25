import UIKit
import SwiftUI

public struct CameraScanView {
  public init() {
  }
}

extension CameraScanView: UIViewControllerRepresentable {

  public func makeUIViewController(context: Context) -> CameraScanViewController {
    let viewController = CameraScanViewController()
    viewController.view.backgroundColor = .red
    return viewController
  }

  public func updateUIViewController(_ uiViewController: CameraScanViewController, context: Context) {
  }

}
