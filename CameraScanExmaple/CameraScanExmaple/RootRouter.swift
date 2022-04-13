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
    case .selectAPicture:
      navigation.pushViewController(makeTakePictureView(), animated: true)
    case let .edit(image, model, isRotateImage):
      navigation.pushViewController(makeEdit(image: image, model: model, isRotateImage: isRotateImage), animated: true)
    case let .flatImage(image):
      navigation.pushViewController(makeFlatImage(image: image), animated: true)
    case .takeAPicture:
      navigation.pushViewController(makeTakePictureView(), animated: true)
    case .takeAPictureForEdgeDetecting:
      navigation.pushViewController(makeTakePictureForEdgeDetectingView(), animated: true)
    }
  }

  // MARK: Private

  private var stack: [String: UIViewController] = [:]

  private let navigation: UINavigationController = .init()

  private func makeHome() -> UIHostingController<AnyView> {
    let view = HomeView(router: self)
    let viewContrlller = UIHostingController(rootView: AnyView(view))
    let viewName = String(describing: view)

    if let prevController = stack[viewName] {
      prevController.navigationController?.popViewController(animated: false)
    }

    stack[viewName] = viewContrlller
    return viewContrlller
  }

  private func makeEdit(image: UIImage, model: Quadrilateral?, isRotateImage: Bool) -> UIHostingController<AnyView> {
    let view = EditPictureView(image: image, quad: model, isRotateImage: isRotateImage, router: self)
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

  private func makeTakePictureView() -> UIHostingController<AnyView> {
    let root = TakePictureView(router: self)
    let viewName = String(describing: root)
    let controller = UIHostingController(rootView: AnyView(root))
    stack[viewName] = controller
    return UIHostingController(rootView: AnyView(root))
  }


  private func makeTakePictureForEdgeDetectingView() -> UIHostingController<AnyView> {
    let root = TakePictureForEdgeDetectingView(router: self)
    let viewName = String(describing: root)
    let controller = UIHostingController(rootView: AnyView(root))
    stack[viewName] = controller
    return UIHostingController(rootView: AnyView(root))
  }

}

extension RootRouter {
  enum RouteType {
    case back
    case takeAPicture
    case takeAPictureForEdgeDetecting
    case selectAPicture
    case edit(image: UIImage, model: Quadrilateral?, isRotateImage: Bool)
    case flatImage(image: UIImage)
  }
}

extension RootRouter {

  static func start() -> AnyView {
    let router = RootRouter()
    let navigation = router.navigation
    navigation.setViewControllers([ router.makeHome() ], animated: false)
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
