import Foundation

class UploadManager {

    static let shared = UploadManager()

    private init() {}

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

        print("📤 Subiendo foto...")

        URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in

            if let error = error {

                print("❌ ERROR SUBIENDO FOTO")

                print(error.localizedDescription)

                return
            }

            if let httpResponse = response as? HTTPURLResponse {

                print("🌐 Status Code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {

                    print("✅ FOTO SUBIDA CORRECTAMENTE")

                } else {

                    print("⚠️ Respuesta inesperada servidor")
                }
            }

        }.resume()
    }
}