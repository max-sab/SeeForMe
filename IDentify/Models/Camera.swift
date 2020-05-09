//
//  Camera.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/1/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import AVFoundation

class Camera: NSObject {

    private var camera: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var cameraInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoCompletion: ((UIImage?, Error?) -> Void)?

    func setupCamera(completion: @escaping (Error?) -> Void) {

        DispatchQueue(label: "com.saba.identify.setupCamera").async {
            do {

                //MARK: Configuring capture session
                self.captureSession = AVCaptureSession()

                //MARK: Congiguring capture device
                guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { throw CameraError.cameraIsMissing }

                try captureDevice.lockForConfiguration()
                captureDevice.autoFocusRangeRestriction = .near
                captureDevice.unlockForConfiguration()
                self.camera = captureDevice

                //MARK: Congiguring device input
                guard let captureSession = self.captureSession else { throw CameraError.captureSessionIsNotFound }

                if let camera = self.camera {
                    self.cameraInput = try AVCaptureDeviceInput(device: camera)
                    if captureSession.canAddInput(self.cameraInput!) { captureSession.addInput(self.cameraInput!) }
                } else {
                    throw CameraError.cameraIsMissing
                }

                //MARK: Configuring photo output
                self.photoOutput = AVCapturePhotoOutput()
                self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)

                if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }

                captureSession.startRunning()
            }

            catch {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }

            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }


    func showCameraPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraError.captureSessionIsNotFound }

        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.connection?.videoOrientation = .portrait
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        self.cameraPreviewLayer?.frame = view.frame
    }

    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraError.captureSessionIsNotFound); return }

        let settings = AVCapturePhotoSettings()

        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCompletion = completion
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            self.photoCompletion?(UIImage(data: data), nil)
        } else {
            self.photoCompletion?(nil, CameraError.photoDataIsInvalid)
        }
    }

    //workaround to remove shutter sound
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}

enum CameraError: Swift.Error {
    case captureSessionIsNotFound
    case cameraIsMissing
    case photoDataIsInvalid
}
