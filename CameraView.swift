import SwiftUI
import AVFoundation
import Combine

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()

    @Published var capturedImages: [Data] = []

    override init() {

        super.init()

        configureSession()
    }

    private func configureSession() {

        session.beginConfiguration()

        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {

            print("❌ No se encontró cámara")

            return
        }

        do {

            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {

                session.addInput(input)
            }

        } catch {

            print("❌ Error creando input cámara")

            return
        }

        if session.canAddOutput(output) {

            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func startSession() {

        DispatchQueue.global(qos: .userInitiated).async {

            if !self.session.isRunning {

                self.session.startRunning()

                print("✅ Cámara iniciada")
            }
        }
    }

    func stopSession() {

        DispatchQueue.global(qos: .userInitiated).async {

            if self.session.isRunning {

                self.session.stopRunning()

                print("🛑 Cámara detenida")
            }
        }
    }

    func takePhoto() {

        let settings = AVCapturePhotoSettings()

        settings.flashMode = .off

        output.capturePhoto(with: settings, delegate: self)

        print("📸 Capturando foto...")
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {

        if let error = error {

            print("❌ Error capturando foto")

            print(error.localizedDescription)

            return
        }

        guard let imageData = photo.fileDataRepresentation() else {

            print("❌ Error generando JPG")

            return
        }

        DispatchQueue.main.async {

            self.capturedImages.append(imageData)

            print("✅ FOTO CAPTURADA")

            print("📦 Total fotos: \(self.capturedImages.count)")

            UploadManager.shared.uploadImage(imageData: imageData)
        }
    }
}

struct CameraView: UIViewRepresentable {

    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {

        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)

        previewLayer.frame = view.bounds

        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        camera.startSession()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}