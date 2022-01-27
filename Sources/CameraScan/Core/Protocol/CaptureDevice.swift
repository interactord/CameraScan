import AVFoundation
import Foundation

// MARK: - CaptureDevice

protocol CaptureDevice: AnyObject {
  var torchMode: AVCaptureDevice.TorchMode { get set }
  var isTorchAvailable: Bool { get }

  var focusMode: AVCaptureDevice.FocusMode { get set }
  var focusPointOfInterest: CGPoint { get set }
  var isFocusPointOfInterestSupported: Bool { get }

  var exposureMode: AVCaptureDevice.ExposureMode { get set }
  var exposurePointOfInterest: CGPoint { get set }
  var isExposurePointOfInterestSupported: Bool { get }

  var isSubjectAreaChangeMonitoringEnabled: Bool { get set }

  func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
  func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
  func unlockForConfiguration()
  func lockForConfiguration() throws
}

// MARK: - AVCaptureDevice + CaptureDevice

extension AVCaptureDevice: CaptureDevice {
}

// MARK: - MockCaptureDevice

final class MockCaptureDevice: CaptureDevice {
  var torchMode: AVCaptureDevice.TorchMode = .off
  var isTorchAvailable: Bool = true
  var focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
  var focusPointOfInterest: CGPoint = .zero
  var isFocusPointOfInterestSupported: Bool = true
  var exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
  var exposurePointOfInterest: CGPoint = .zero
  var isExposurePointOfInterestSupported: Bool = true
  var isSubjectAreaChangeMonitoringEnabled: Bool = false

  func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool { true }

  func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool { true }

  func unlockForConfiguration() {
  }

  func lockForConfiguration() throws {
  }
}
