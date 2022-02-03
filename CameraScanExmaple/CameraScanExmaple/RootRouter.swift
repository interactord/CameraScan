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
    case let .edit(image, model):
      navigation.pushViewController(makeEdit(image: image, model: model), animated: true)
    case let .flatImage(image):
      navigation.pushViewController(makeFlatImage(image: image), animated: true)
    }
  }

  // MARK: Private

  private var stack: [String: UIViewController] = [:]

  private let navigation: UINavigationController = .init()

  private func makeEdit(image: UIImage, model: Quadrilateral?) -> UIHostingController<AnyView> {
    let view = EditPictureView(image: image, quad: model, router: self)
    let viewController = UIHostingController(rootView: AnyView(view))
    let viewName = String(describing: view)

    if let prevController = stack[viewName] {
      prevController.navigationController?.popViewController(animated: false)
    }

    stack[viewName] = viewController
    return viewController

  }

  private func makeFlatImage(image: UIImage) -> UIHostingController<AnyView> {
    let view = FlatImageView(image: image)
    let viewController = UIHostingController(rootView: AnyView(view))
    let viewName = String(describing: view)

    if let prevController = stack[viewName] {
      prevController.navigationController?.popViewController(animated: false)
    }

    stack[viewName] = viewController
    return viewController
  }

  private func makeRoot() -> UIHostingController<AnyView> {
    let root = TakePictureView(router: self)
    let viewName = String(describing: root)
    let controller = UIHostingController(rootView: AnyView(root))
    stack[viewName] = controller
    return UIHostingController(rootView: AnyView(root))
  }

}

extension RootRouter {
  enum RouteType {
    case back
    case edit(image: UIImage, model: Quadrilateral?)
    case flatImage(image: UIImage)
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
