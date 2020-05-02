//
//  CameraController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/1/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject {

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
                guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { throw CameraControllerError.cameraIsMissing }

                self.camera = captureDevice
                try captureDevice.lockForConfiguration()
                //captureDevice.videoZoomFactor = 2
                captureDevice.autoFocusRangeRestriction = .near
                captureDevice.unlockForConfiguration()

                //MARK: Congiguring device input
                guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsNotFound }

                if let camera = self.camera {
                    self.cameraInput = try AVCaptureDeviceInput(device: camera)
                    if captureSession.canAddInput(self.cameraInput!) { captureSession.addInput(self.cameraInput!) }
                } else {
                    throw CameraControllerError.cameraIsMissing
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


    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsNotFound }

        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        self.cameraPreviewLayer?.frame = view.frame
    }

    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsNotFound); return }

        let settings = AVCapturePhotoSettings()

        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCompletion = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation() {
            self.photoCompletion?(UIImage(data: data), nil)
        } else {
            self.photoCompletion?(nil, CameraControllerError.photoDataIsInvalid)
        }
    }

    //workaround to remove shutter soundso
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}

enum CameraControllerError: Swift.Error {
    case captureSessionIsNotFound
    case cameraIsMissing
    case photoDataIsInvalid
}
