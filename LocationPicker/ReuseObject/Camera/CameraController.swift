import AVFoundation
import UIKit

enum CameraControllerError: Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

public enum CameraPosition {
    case front
    case rear
}

class CameraController: NSObject {
    
    
    var nowPlayingView: UIView?
    
    var captureCompletionHandler : ((UIImage) -> Void )!
    var CurrentImage : UIImage?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var flashMode = AVCaptureDevice.FlashMode.off
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var MainphotoOutput: AVCapturePhotoOutput?
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession()  {
            self.captureSession = AVCaptureSession()
            captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        }
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }
            
            guard !cameras.isEmpty else {
                throw CameraControllerError.noCamerasAvailable }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
            //1
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            //2
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentDevice = self.rearCamera
            }
            
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentDevice = self.frontCamera
            }
            
            else { throw CameraControllerError.noCamerasAvailable }
        }
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.MainphotoOutput = AVCapturePhotoOutput()
            self.MainphotoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.MainphotoOutput!) { captureSession.addOutput(self.MainphotoOutput!) }
            
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
            
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
}
extension CameraController {
    func displayPreview(on view: UIView) throws {
        
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer!.frame = view.bounds
        nowPlayingView = view
    }
    
    func ChangePreView(on view: UIView) throws {
        
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        if self.nowPlayingView === view {
            self.previewLayer!.frame = view.bounds
        } else {
            self.previewLayer!.frame = view.bounds
            view.layer.insertSublayer(self.previewLayer!, at: 0)
        }
        nowPlayingView = view
    }
}

extension CameraController {
    
    func capture(completion: @escaping (UIImage) -> Void) {
        captureCompletionHandler = completion
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = self.flashMode
        
        if currentDevice == frontCamera {
            MainphotoOutput?.connection(with: .video)?.isVideoMirrored = true
        }
        MainphotoOutput?.isHighResolutionCaptureEnabled = true
        MainphotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func toggleCamera() {
        if let captureSession = captureSession {
            captureSession.beginConfiguration()
            // 依照目前的相機變更裝置
            guard let newDevice = (currentDevice == rearCamera) ? frontCamera : rearCamera else {
                return
            }
            // 從 session 中移除所有的輸入
            for input in captureSession.inputs {
                captureSession.removeInput(input as! AVCaptureDeviceInput) }
            // 變更為新的輸入
            let cameraInput:AVCaptureDeviceInput
            do {
                cameraInput = try AVCaptureDeviceInput(device: newDevice) } catch {
                    print(error.localizedDescription)
                    return
                }
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
            currentDevice = newDevice
            captureSession.commitConfiguration()
        }
    }
    
    func changeCamera(to camera : AVCaptureDevice.Position) {
        if let captureSession = captureSession {
            captureSession.beginConfiguration()
            // 依照目前的相機變更裝置
            guard let newDevice = (camera == AVCaptureDevice.Position.front) ? frontCamera : rearCamera,
                  camera != currentDevice?.position
            else {
                return
            }
            // 從 session 中移除所有的輸入
            for input in captureSession.inputs {
                captureSession.removeInput(input as! AVCaptureDeviceInput) }
            // 變更為新的輸入
            let cameraInput:AVCaptureDeviceInput
            do {
                cameraInput = try AVCaptureDeviceInput(device: newDevice) } catch {
                    print(error.localizedDescription)
                    return
                }
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
            currentDevice = newDevice
            captureSession.commitConfiguration()
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        if let image = UIImage(data: imageData) {
            captureCompletionHandler(image)
            CurrentImage = image
        } else {
            return
        }

    }
    
}

