import AVFoundation
import CoreMotion
import UIKit

// MARK: - RectangleDetectionDelegateProtocol

protocol RectangleDetectionDelegateProtocol: NSObjectProtocol {
  /// - Note: Called when the capture of a picture has started.
  func didStartCapturingPicture(sessionManager: CaptureSessionManager)

  /// - Note: Called when a quadrilateral has been detected.
  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, imageSize: CGSize)

  /// - Note: Called when a picture with or without a quadrilateral has been captured.
  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePricture image: UIImage, quad: Quadrilateral?)

  /// - Note: Called when an error occured with the capture session manager.
  func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFail error: CameraScanError)
}

// MARK: - CaptureSessionManager

final class CaptureSessionManager: NSObject {

  // MARK: Lifecycle

  init?(
    videoPreviewLayer: AVCaptureVideoPreviewLayer,
    delegate: RectangleDetectionDelegateProtocol? = nil)
  {
    self.videoPreviewLayer = videoPreviewLayer
    self.delegate = delegate

    super.init()

    guard let device = AVCaptureDevice.default(for: .video) else {
      delegate?.captureSessionManager(self, didFail: .inputDevice)
      return nil
    }

    captureSession.beginConfiguration()
    photoOutput.isHighResolutionCaptureEnabled = true

    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.alwaysDiscardsLateVideoFrames = true

    defer {
      device.unlockForConfiguration()
      captureSession.commitConfiguration()
    }

    guard
      let deviceInput = try? AVCaptureDeviceInput(device: device),
      captureSession.canAddInput(deviceInput),
      captureSession.canAddOutput(photoOutput),
      captureSession.canAddOutput(videoOutput)
    else {
      delegate?.captureSessionManager(self, didFail: .inputDevice)
      return
    }

    do {
      try device.lockForConfiguration()
    } catch {
      delegate?.captureSessionManager(self, didFail: .inputDevice)
      return
    }

    deviceInput.device.isSubjectAreaChangeMonitoringEnabled = true

    captureSession.addInput(deviceInput)
    captureSession.addOutput(photoOutput)
    captureSession.addOutput(videoOutput)

    let preset = AVCaptureSession.Preset.photo

    if captureSession.canSetSessionPreset(preset) {
      captureSession.sessionPreset = preset
      photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureEnabled
    }

    videoPreviewLayer.session = captureSession
    videoPreviewLayer.videoGravity = .resizeAspectFill

    videoOutput.setSampleBufferDelegate(self, queue: .init(label: "video_output_queue"))
  }

  // MARK: Internal

  weak var delegate: RectangleDetectionDelegateProtocol?

  // MARK: Private

  private struct Const {
    /// - Note: The minimum number of time required by `noRectangleCount` to validate that no rectangles have been found.
    static let noRectangleThreshold: Int = 3
  }

  private let videoPreviewLayer: AVCaptureVideoPreviewLayer
  private let captureSession: AVCaptureSession = .init()
  private let funnel = RectangleFeaturesFunnel()
  private var displyedRectanleResult: RectangleDetectorResult?
  private var photoOutput = AVCapturePhotoOutput()

  /// - Note: Whether the CaptureSessionManager should be detecting quadrilaterals.
  private var isDetecting = true

  /// - Note: The number of times no rectangles have been found in a row.
  private var noRectanleCount: Int = .zero

}

extension CaptureSessionManager {

  // MARK: Internal

  func start() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      DispatchQueue.main.async { [weak self] in
        self?.captureSession.startRunning()
      }
      isDetecting = true
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { _ in
        DispatchQueue.main.async { [weak self] in
          self?.start()
        }
      }
    default:
      delegate?.captureSessionManager(self, didFail: .authorization)
    }
  }

  func stop() {
    captureSession.stopRunning()
  }

  func capturePhoto() {
    guard
      let connection = photoOutput.connection(with: .video),
      connection.isEnabled,
      connection.isActive
    else {
      delegate?.captureSessionManager(self, didFail: .capture)
      return
    }

    CaptureSession.current.setImageOrientation()
    let settings = AVCapturePhotoSettings()
    settings.isHighResolutionPhotoEnabled = true
    photoOutput.capturePhoto(with: settings, delegate: self)

  }

  // MARK: Private

  private func process(rectangle: Quadrilateral, imageSize: CGSize) {
    noRectanleCount = .zero
    funnel.add(feature: rectangle, current: displyedRectanleResult?.rectanle) { [weak self] result, _ in
      let shouldAutoScan = result == .showAndAutoScan
      self?.displayRectangle(result: .init(rectanle: rectangle, imageSize: imageSize))
      if shouldAutoScan, CaptureSession.current.isAutoScanEnabled, !CaptureSession.current.isEditing {
        self?.capturePhoto()
      }
    }
  }

  private func processNotFoundModel(imageSize: CGSize) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.noRectanleCount += 1

      guard self.noRectanleCount > Const.noRectangleThreshold else { return }
      self.funnel.currentAutoScanPassCount = .zero
      self.displyedRectanleResult = .none
      self.delegate?.captureSessionManager(self, didDetectQuad: .none, imageSize: imageSize)
    }
  }

  @discardableResult
  private func displayRectangle(result: RectangleDetectorResult) -> Quadrilateral {
    let quad = result.rectanle.toCartesian(height: result.imageSize.height)

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.delegate?.captureSessionManager(self, didDetectQuad: quad, imageSize: result.imageSize)
    }
    return quad
  }

}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard isDetecting == true, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let size: CGSize = .init(
      width: CVPixelBufferGetWidth(pixelBuffer),
      height: CVPixelBufferGetHeight(pixelBuffer))
    VisionRectangleDetector.rectangle(pixelBuffer: pixelBuffer) { [weak self] in
      if let model = $0 {
        self?.process(rectangle: model, imageSize: size)
      } else {
        self?.processNotFoundModel(imageSize: size)
      }
    }
  }
}

// MARK: AVCapturePhotoCaptureDelegate

extension CaptureSessionManager: AVCapturePhotoCaptureDelegate {

  // MARK: Internal

  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if error != nil {
      delegate?.captureSessionManager(self, didFail: .capture)
      return
    }

    isDetecting = false
    funnel.currentAutoScanPassCount = .zero
    delegate?.didStartCapturingPicture(sessionManager: self)

    guard let imageData = photo.fileDataRepresentation() else {
      delegate?.captureSessionManager(self, didFail: .capture)
      return
    }
    completedImageCapture(data: imageData)
  }

  // MARK: Private

  /// - Note:
  ///   - Completes the image capture by processing the image, and passing it to the delegate object.
  ///   - This function is necessary because the capture functions for iOS 10 and 11 are decoupled.
  private func completedImageCapture(data: Data) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      CaptureSession.current.isEditing = true
      guard let image = UIImage(data: data) else {
        DispatchQueue.main.async {
          guard let self = self else { return }
          self.delegate?.captureSessionManager(self, didFail: .capture)
        }
        return
      }

      var angle: CGFloat {
        switch image.imageOrientation {
        case .right: return CGFloat.pi / 2
        case.up: return CGFloat.pi
        default: return .zero
        }
      }

      var quad: Quadrilateral?
      if let result = self?.displyedRectanleResult {
        quad = self?.displayRectangle(result: result)
          .scale(from: result.imageSize, to: image.size, angle: angle)
      }

      DispatchQueue.main.async {
        guard let self = self else { return }
        self.delegate?.captureSessionManager(self, didCapturePricture: image, quad: quad)
      }

    }
  }
}

// MARK: - RectangleDetectorResult

private struct RectangleDetectorResult {
  let rectanle: Quadrilateral
  let imageSize: CGSize
}

extension CaptureSession {

  /// - Note: Detect the current orientation of the device with CoreMotion and use it to set the `editImageOrientation`.
  func setImageOrientation() {
    let motion = CMMotionManager()

    /// This value should be 0.2, but since we only need one cycle (and stop updates immediately),
    /// we set it low to get the orientation immediately
    motion.accelerometerUpdateInterval = 0.01

    motion.startAccelerometerUpdates(to: .init()) { data, error in
      guard let data = data, error == nil else { return }

      /// The minimum amount of sensitivity for the landscape orientations
      /// This is to prevent the landscape orientation being incorrectly used
      /// Higher = easier for landscape to be detected, lower = easier for portrait to be detected
      let motionThreshold = 0.35

      switch data.acceleration.x {
      case let x where x >= motionThreshold:
        self.editImageOrientation = .left
      case let x where x <= -motionThreshold:
        self.editImageOrientation = .right
      default:
        /// This means the device is either in the 'up' or 'down' orientation, BUT,
        /// it's very rare for someone to be using their phone upside down, so we use 'up' all the time
        /// Which prevents accidentally making the document be scanned upside down
        self.editImageOrientation = .up
      }

      motion.stopAccelerometerUpdates()

      switch UIDevice.current.orientation {
      case .landscapeLeft:
        self.editImageOrientation = .right
      case .landscapeRight:
        self.editImageOrientation = .left
      default:
        break
      }
    }
  }
}
