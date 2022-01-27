import CameraScan
import Foundation
import SwiftUI
import UIKit

// MARK: - RootRouter

final class RootRouter {

  // MARK: Lifecycle

  private init() {
  }

  // MARK: Internal

  static let shared = RootRouter()

  func navigatedTo(type: RouteType) {
    switch type {
    case .back:
      guard stack.count > 1 else { return }
      navigation.popViewController(animated: false)
    default:
      break
//    case .edit(image: UIImage, model: Quadrilateral?):

    }
  }

  // MARK: Private

  private var stack: [String] = []

  private let navigation: UINavigationController = .init()

//  private func makeEdit(image: UIImage, model: Quadrilateral) -> UIHostingController<AnyView> {
//    stack.ap
//
//  }

  private func makeRoot() -> UIHostingController<AnyView> {
    let root = TakePictureView(router: self)
    stack.append(String(describing: TakePictureView.self))
    return UIHostingController(rootView: AnyView(root))
  }

}

extension RootRouter {
  enum RouteType {
    case back
    case edit(image: UIImage, model: Quadrilateral?)
  }
}

extension RootRouter {

  static func start() -> AnyView {
    let router = RootRouter()
    let navigation = router.navigation
    navigation.setViewControllers([ router.makeRoot() ], animated: false)
    return AnyView(RootNavigation(navigation: navigation))
  }
}

// MARK: - RootNavigation

struct RootNavigation: UIViewControllerRepresentable {

  init(navigation: UINavigationController) {
    self.navigation = navigation
  }

  let navigation: UINavigationController

  func makeUIViewController(context: Context) -> UINavigationController {
    navigation
  }

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
  }

}
