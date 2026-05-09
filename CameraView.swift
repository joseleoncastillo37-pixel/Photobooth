import SwiftUI
import AVFoundation

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    let session = AVCaptureSession()

    let output = AVCapturePhotoOutput()

    @Published var capturedImages: [Data] = []

    func startSession() {

        session.beginConfiguration()

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {

            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {

            return
        }

        if session.canAddInput(input) {

            session.addInput(input)
        }

        if session.canAddOutput(output) {

            session.addOutput(output)
        }

        session.sessionPreset = .photo

        session.commitConfiguration()

        session.startRunning()
    }

    func takePhoto() {

        let settings = AVCapturePhotoSettings()

        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {

        guard let imageData = photo.fileDataRepresentation() else {

            return
        }

        DispatchQueue.main.async {

            self.capturedImages.append(imageData)

            UploadManager.shared.uploadImage(imageData: imageData)

           print("📸 FOTO REAL CAPTURADA")

           print("Total fotos: \\(self.capturedImages.count)")
        }
    }
}

struct CameraView: UIViewRepresentable {

    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {

        let view = UIView(frame: UIScreen.main.bounds)

        camera.startSession()

        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)

        previewLayer.frame = view.bounds

        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}