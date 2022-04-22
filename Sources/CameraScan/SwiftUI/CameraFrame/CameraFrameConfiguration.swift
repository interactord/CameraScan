import AVFoundation
import Foundation

// MARK: - CameraFrameConfiguration

struct CameraFrameConfiguration {

  let captureSession: AVCaptureSession
  let currentCamera: AVCaptureDevice?
  let photoOutput: AVCapturePhotoOutput?
  let previewLayer: AVCaptureVideoPreviewLayer?

  func mutate(captureSession: AVCaptureSession) -> Self {
    Self.init(
      captureSession: captureSession,
      currentCamera: currentCamera,
      photoOutput: photoOutput,
      previewLayer: previewLayer)
  }

  func mutate(currentCamera: AVCaptureDevice?) -> Self {
    Self.init(
      captureSession: captureSession,
      currentCamera: currentCamera,
      photoOutput: photoOutput,
      previewLayer: previewLayer)
  }

  func mutate(photoOutput: AVCapturePhotoOutput?) -> Self {
    Self.init(
      captureSession: captureSession,
      currentCamera: currentCamera,
      photoOutput: photoOutput,
      previewLayer: previewLayer)
  }

  func mutate(previewLayer: AVCaptureVideoPreviewLayer?) -> Self {
    Self.init(
      captureSession: captureSession,
      currentCamera: currentCamera,
      photoOutput: photoOutput,
      previewLayer: previewLayer)
  }
}

extension CameraFrameConfiguration {
  fileprivate func mutateDevice() -> Self {
    mutate(currentCamera: AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInDualWideCamera],
      mediaType: .video,
      position: .unspecified)
      .devices
      .first(where: { $0.position == .back }))
  }

  fileprivate func mutateInOutput() -> Self {
    guard
      let currentCamera = currentCamera,
      let input = try? AVCaptureDeviceInput(device: currentCamera) else
    {
      return self
    }

    let captureSession = captureSession
    captureSession.sessionPreset = .photo
    captureSession.addInput(input)

    let output = AVCapturePhotoOutput()
    output.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
    captureSession.addOutput(output)

    return mutate(captureSession: captureSession)
      .mutate(photoOutput: output)
  }

  fileprivate func mutatePreviewLayer() -> Self {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = .resizeAspectFill
    layer.connection?.videoOrientation = .portrait
    return mutate(previewLayer: layer)
  }
}

extension CameraFrameConfiguration {
  static var `default`: Self {
    Self.init(
      captureSession: .init(),
      currentCamera: .none,
      photoOutput: .none,
      previewLayer: .none)
      .mutateDevice()
      .mutateInOutput()
      .mutatePreviewLayer()
  }
}
