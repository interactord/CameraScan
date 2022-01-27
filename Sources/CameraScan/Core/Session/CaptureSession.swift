import AVFoundation
import Foundation

// MARK: - CaptureSession

final class CaptureSession {

  // MARK: Lifecycle

  private init(isAutoScanEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
    device = AVCaptureDevice.default(for: .video)
    isEditing = false
    self.isAutoScanEnabled = isAutoScanEnabled
    self.editImageOrientation = editImageOrientation
  }

  // MARK: Internal

  static let current: CaptureSession = .init()

  var device: CaptureDevice?
  var isEditing: Bool
  var isAutoScanEnabled: Bool
  var editImageOrientation: CGImagePropertyOrientation

}

extension CaptureSession {

  func resetFocusToAuto() throws {
    guard let device = device else { throw CameraScanError.inputDevice }

    try device.lockForConfiguration()

    defer {
      device.unlockForConfiguration()
    }

    if
      device.isFocusPointOfInterestSupported,
      device.isFocusModeSupported(.continuousAutoFocus)
    {
      device.focusMode = .continuousAutoFocus
    }

    if
      device.isExposurePointOfInterestSupported,
      device.isExposureModeSupported(.continuousAutoExposure)
    {
      device.exposureMode = .continuousAutoExposure
    }
  }
}
