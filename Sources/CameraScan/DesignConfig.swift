import UIKit

// MARK: - DesignConfig

public struct DesignConfig {
  public struct BoxLayer {

    // MARK: Lifecycle

    public init(edit: LayerStyleModel, noEdit: LayerStyleModel) {
      self.edit = edit
      self.noEdit = noEdit
    }

    // MARK: Public

    public let edit: LayerStyleModel
    public let noEdit: LayerStyleModel

    public static func defaultValue() -> Self {
      .init(
        edit: .init(
          fillColor: .init(white: .zero, alpha: 0.6),
          strokeColor: .white,
          strokeWidth: 1.0),
        noEdit: .init(
          fillColor: .init(white: 1.0, alpha: 0.5),
          strokeColor: .white,
          strokeWidth: 1.0))
    }

    // MARK: Internal

    func apply(isEditing: Bool) -> LayerStyleModel {
      isEditing ? edit : noEdit
    }

  }

  public struct EditPointLayer {

    // MARK: Lifecycle

    public init(edit: LayerRectConfigModel, noEdit: LayerRectConfigModel) {
      self.edit = edit
      self.noEdit = noEdit
    }

    // MARK: Public

    public let edit: LayerRectConfigModel
    public let noEdit: LayerRectConfigModel

    public static func defaultValue() -> Self {
      .init(
        edit: .init(
          style: .init(
            fillColor: .clear,
            strokeColor: .white,
            strokeWidth: 1.0),
          squareSize: 75.0),
        noEdit: .init(
          style: .init(
            fillColor: .clear,
            strokeColor: .white,
            strokeWidth: 1.0),
          squareSize: 20.0))
    }

    // MARK: Internal

    func apply(isEditing: Bool) -> LayerRectConfigModel {
      isEditing ? edit : noEdit
    }

  }
}

extension DesignConfig {
  public struct LayerRectConfigModel {
    public let style: LayerStyleModel
    public let squareSize: CGFloat

    public init(style: LayerStyleModel, squareSize: CGFloat) {
      self.style = style
      self.squareSize = squareSize
    }
  }

  public struct LayerStyleModel {
    public let fillColor: UIColor
    public let strokeColor: UIColor
    public let strokeWidth: CGFloat

    public init(fillColor: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) {
      self.fillColor = fillColor
      self.strokeColor = strokeColor
      self.strokeWidth = strokeWidth
    }
  }
}
