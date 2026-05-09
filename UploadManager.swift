import Foundation

class UploadManager {

    static let shared = UploadManager()

    private init() {}

    // CAMBIA ESTA IP SI TU SERVIDOR CAMBIA
    private let serverURL = "http://172.16.20.103/upload"

    func uploadImage(imageData: Data) {

        guard let url = URL(string: serverURL) else {

            print("❌ URL inválida")

            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.timeoutInterval = 30

        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

        print("📤 Subiendo foto al servidor...")

        let task = URLSession.shared.uploadTask(
            with: request,
            from: imageData
        ) { data, response, error in

            if let error = error {

                print("❌ ERROR SUBIENDO FOTO")

                print(error.localizedDescription)

                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {

                print("❌ Respuesta inválida servidor")

                return
            }

            print("🌐 Status Code: \(httpResponse.statusCode)")

            switch httpResponse.statusCode {

            case 200:

                print("✅ FOTO SUBIDA CORRECTAMENTE")

            case 404:

                print("⚠️ Endpoint /upload no encontrado")

            case 500:

                print("⚠️ Error interno servidor")

            default:

                print("⚠️ Respuesta inesperada")
            }
        }

        task.resume()
    }
}