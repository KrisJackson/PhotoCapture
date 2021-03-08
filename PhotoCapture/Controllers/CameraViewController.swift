//
//  CameraViewController.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/5/21.
//

import UIKit
import PhotosUI
import AVFoundation

protocol MediaDelegate {
    func cameraViewController(maxNumberOfImageCapturedIn viewController: UIViewController) -> Int
    func cameraViewController(_ viewController: UIViewController, didCaptureImages images: [UIImage])
    func cameraViewController(shouldNavigateToPreviousViewControllerFrom viewController: UIViewController)
}

class CameraViewController: UIViewController {
    
    static let storyboardID = "CameraViewController"

    @IBOutlet weak private var slider: UISlider!
    @IBOutlet weak private var imageFrame: UIView!
    @IBOutlet weak private var flipButton: FlipButton!
    @IBOutlet weak private var closeButton: BlurButton!
    @IBOutlet weak private var flashButton: FlashButton!
    @IBOutlet weak private var captureButton: CaptureButton!
    @IBOutlet weak private var continueButton: ContinueButton!
    @IBOutlet weak private var photoLibraryButton: PhotosButton!
    @IBOutlet weak private var permissionWarning: CameraPrivacyView!
    
    var delegate: MediaDelegate?
    
    private var maxNumberOfImages: Int!
    private var captureSession: AVCaptureSession?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private var zoomFactor: CGFloat = 1.0
    private let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
    
    private var photos: [UIImage] = [] {
        didSet {
            self.continueButton.isHidden = self.photos.isEmpty
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.slider.value = 1
        self.slider.maximumValue = 4
        self.maxNumberOfImages = self.delegate?.cameraViewController(maxNumberOfImageCapturedIn: self)
        
        self.flipButton.delegate = self
        self.captureButton.delegate = self
        self.continueButton.delegate = self
        self.photoLibraryButton.delegate = self
        
        self.closeButton.style = .systemUltraThinMaterialLight
        self.closeButton.button.addTarget(self, action: #selector(self.closePressed), for: .touchUpInside)
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            DispatchQueue.main.async {
                self.permissionWarning.isHidden = response
                self.slider.isUserInteractionEnabled = response
                self.flipButton.isUserInteractionEnabled = response
                self.flashButton.isUserInteractionEnabled = response
                self.captureButton.isUserInteractionEnabled = response
                response ? (self.slider.value = 1.0) : (self.slider.value = ((self.slider.maximumValue + 1) / 2))
                if response { self.setupAndStartCaptureSession() }
            }
        }
        
        /// Enables 'slide to dismiss' for views added to stack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Configure super view
        /// Add rounded corners to iPhone X family
        if window?.safeAreaInsets.bottom ?? 0 > 0 {
            self.view.layer.cornerRadius = 30
            self.view.layer.masksToBounds = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.captureSession?.startRunning()
        }
        
        /// Configure super view
        /// Remove rounded corners to iPhone X family
        if window?.safeAreaInsets.bottom ?? 0 > 0 {
            self.view.layer.cornerRadius = 0
            self.view.layer.masksToBounds = true
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Configure super view
        /// Add rounded corners to iPhone X family
        if window?.safeAreaInsets.bottom ?? 0 > 0 {
            self.view.layer.cornerRadius = 30
            self.view.layer.masksToBounds = true
        }
        
        self.captureSession?.stopRunning()
    }
    
    func removeImage(at index: Int) -> UIImage {
        self.photos.remove(at: index)
    }
    
    
    /// Close camera
    @objc func closePressed(_ sender: Any) {
        self.delegate?.cameraViewController(shouldNavigateToPreviousViewControllerFrom: self)
    }
    
    
    /// Zoom in and out when user pinches screen
    @IBAction func pinchToZoom(_ sender: Any) {
        
        guard let pinch = sender as? UIPinchGestureRecognizer else { return}
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 1.0), 5)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                debugPrint(error)
            }
        }

        let newScaleFactor = minMaxZoom(pinch.scale * self.zoomFactor)
        self.slider.value = Float(newScaleFactor)

        switch pinch.state {
        case .began:
            fallthrough
        case .changed:
            update(scale: newScaleFactor)
        case .ended:
            self.zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: self.zoomFactor)
        default:
            break
        }
        
    }
    
    
    /// Zoom in the camera when user interacts with the slider
    @IBAction func sliderValueChanged(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            let newZoomFactor = CGFloat(self.slider.value)
            self.zoomFactor = newZoomFactor
            device.videoZoomFactor = newZoomFactor
            
        } catch {
            debugPrint(error)
        }
    }
    
    
    /// The camera focuses on the location of the tap gesture
    @IBAction func tapToFocus(_ sender: Any) {
        
        guard let sender = sender as? UITapGestureRecognizer else { return }
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        let focusPoint = sender.location(in: self.view)
        let focusScaledPointX = focusPoint.x / self.view.frame.size.width
        let focusScaledPointY = focusPoint.y / self.view.frame.size.height
        
        if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
            do {
                try device.lockForConfiguration()
            } catch {
                print("ERROR: Could not lock camera device for configuration")
                return
            }
            
            device.focusMode = .continuousAutoFocus
            device.exposureMode = .continuousAutoExposure
            device.focusPointOfInterest = CGPoint(x: focusScaledPointX, y: focusScaledPointY)
            device.exposurePointOfInterest = CGPoint(x: focusScaledPointX, y: focusScaledPointY)
            device.unlockForConfiguration()
        }
    }
    
    private func errorAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func alert(title: String, message: String, action: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { _ in
            handler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setupAndStartCaptureSession() {
        
        self.captureSession { (captureSession) in
        
            guard let captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video) else {
                return
            }
            
            do {
                
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                
                self.capturePhotoOutput = AVCapturePhotoOutput()
                self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                captureSession.addOutput(self.capturePhotoOutput!)
                
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoPreviewLayer?.frame = self.view.layer.bounds
                
                guard let videoPreviewLayer = self.videoPreviewLayer else {
                    return
                }
                
                self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
                
            } catch {
                print(error)
            }
            
        }
    }
    
    /// Initializes begins and commit configuration to capture session
    private func captureSession(_ completion: @escaping(_ captureSession: AVCaptureSession) -> Void) {
        
        if self.captureSession == nil {
            self.captureSession = AVCaptureSession()
        }
        self.captureSession?.beginConfiguration()
        completion(self.captureSession!)
        self.captureSession?.commitConfiguration()
        self.captureSession?.startRunning()
    }
    
    private func presentImagePickerViewController() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = (self.maxNumberOfImages ?? 10) - self.photos.count
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .fullScreen
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    private func presentPreview(with image: UIImage) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: PhotoPreviewViewController.storyboardID) as! PhotoPreviewViewController
        viewController.delegate = self
        viewController.image = image
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
}


extension CameraViewController: FlipDelegate {
    
    func flipButtonPressed() {
        
        guard let session = self.captureSession else { return }
        guard let input: AVCaptureDeviceInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        session.beginConfiguration()
        session.removeInput(input)
        
        var newCamera: AVCaptureDevice! = nil
        if (input.device.position == .back) {
            
            self.slider.isHidden = true
            newCamera = self.cameraWithPosition(position: .front)
            
        } else {
            
            self.zoomFactor = 1.0
            self.slider.value = 1
            self.slider.isHidden = false
            newCamera = self.cameraWithPosition(position: .back)
        }
            
        do {
            let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            session.addInput(newVideoInput)
        } catch let error as NSError {
            print("Error creating capture device input: \(error.localizedDescription)")
        }

        //Commit all the configuration changes at once
        session.commitConfiguration()
        
    }
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }

}


extension CameraViewController: CaptureDelegate {
    func captureIsPressed() {
        
        if self.photos.count == self.maxNumberOfImages {
            
            self.alert(
                title: NSLocalizedString("MAX_IMAGE_ALERT_TITLE", comment: "Alert Title"),
                message:  NSLocalizedString("MAX_IMAGE_ALERT_MESSAGE", comment: "Alert Message"),
                action: NSLocalizedString("CONTINUE_BUTTON", comment: "Button")
            ) {
                DispatchQueue.main.async {
                    self.delegate?.cameraViewController(self, didCaptureImages: self.photos)
                }
            }
            
        } else {
            
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            let photoSettings = AVCapturePhotoSettings()
            // Set photo settings for our need
            photoSettings.flashMode = self.flashButton.mode
            photoSettings.isHighResolutionPhotoEnabled = false
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
            
        }
    }
}


extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        
        // Make sure we get some photo sample buffer
        guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
            
        
        // Get image data
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialize UIImage with image data
        guard let capturedImage = UIImage(data: imageData, scale: 1.0) else {
            return
        }
        
        // If front camera is enabled, flip image
        var image = capturedImage
        guard let session = self.captureSession else { return }
        guard let input: AVCaptureDeviceInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        
        if input.device.position == .front {
            if let cgImage = image.cgImage {
                image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
            }
        }
        
        // Image has been taken and collected
        // Display the image preview as a pop up window
        self.presentPreview(with: image)
        
    }
}


// MARK: - Photos Delegate


extension CameraViewController: PhotosDelegate {
    
    func photosButtonPressed() {
        
        if self.photos.count == self.maxNumberOfImages {
            
            self.alert(
                title: NSLocalizedString("MAX_IMAGE_ALERT_TITLE", comment: "Alert Title"),
                message:  NSLocalizedString("MAX_IMAGE_ALERT_MESSAGE", comment: "Alert Message"),
                action: NSLocalizedString("CONTINUE_TO_BUTTON", comment: "Button")
            ) {
                DispatchQueue.main.async {
                    self.delegate?.cameraViewController(self, didCaptureImages: self.photos)
                }
            }
            
        } else {
            
            self.presentImagePickerViewController()
            
        }
        
    }

}


// MARK: - PHPicker View Controller Delegate


extension CameraViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        _ = results.map({
            $0.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        self.errorAlert(
                            title: NSLocalizedString("IMAGE_ERROR_ALERT_TITLE", comment: "Alert Title"),
                            message: error.localizedDescription,
                            action: NSLocalizedString("DISMISS_BUTTON", comment: "Button")
                        )
                        return
                    }
                    
                    if let image = image as? UIImage, error == nil {
                        self.photos.append(image)
                        return
                    }
                    
                }
            }
        })
        
    }
    
}


// MARK: - Photo Preview Delegate


extension CameraViewController: PhotoPreviewDelegate {
    
    func preview(_ preview: PhotoPreviewViewController, didUse image: UIImage) {
        self.photos.append(image)
    }
    
}


// MARK: - Continue Button Delegate


extension CameraViewController: ContinueButtonDelegate {
    
    func continuePressed() {
        self.delegate?.cameraViewController(self, didCaptureImages: self.photos)
    }
    
}


// MARK: - UI Gesture Recognizer Delegate


extension CameraViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        /// Prevents 'slide to dismiss' for view on the root of stack
        ((navigationController?.viewControllers.count ?? 1) > 1) ? true : false
    }
    
}
