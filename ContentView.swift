import SwiftUI

struct ContentView: View {

    @StateObject var camera = CameraModel()

    @State private var countdown = 0
    @State private var currentShot = 1
    @State private var totalShots = 3

    @State private var isCapturing = false
    @State private var showSettings = false

    var body: some View {

        ZStack {

            CameraView(camera: camera)
                .ignoresSafeArea()

            VStack(spacing: 40) {

                if isCapturing {

                    Text("📸 FOTO \(currentShot)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }

                if countdown > 0 {

                    Text("\(countdown)")
                        .font(.system(size: 150, weight: .bold))
                        .foregroundColor(.white)

                } else {

                    Text("PHOTOBOOTH")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .onLongPressGesture {

                            showSettings = true
                        }

                    Button(action: {

                        startCountdown()

                    }) {

                        Text("TOCA PARA COMENZAR")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(width: 350, height: 90)
                            .background(Color.white)
                            .cornerRadius(20)
                    }

                    Text("Modo actual: \(totalShots) fotos")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showSettings) {

            VStack(spacing: 30) {

                Text("CONFIGURACIÓN")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Button("1 FOTO") {

                    totalShots = 1
                    showSettings = false
                }

                Button("2 FOTOS") {

                    totalShots = 2
                    showSettings = false
                }

                Button("3 FOTOS") {

                    totalShots = 3
                    showSettings = false
                }

                Text("Actual: \(totalShots) fotos")
                    .padding(.top, 30)
            }
            .padding()
        }
    }

    func startCountdown() {

        countdown = 3

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in

            if countdown > 1 {

                countdown -= 1

            } else {

                timer.invalidate()

                countdown = 0

                capturePhoto()
            }
        }
    }

    func capturePhoto() {

        isCapturing = true

        camera.takePhoto()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            isCapturing = false

            if currentShot < totalShots {

                currentShot += 1

                startCountdown()

            } else {

                currentShot = 1
            }
        }
    }
}

#Preview {

    ContentView()
}