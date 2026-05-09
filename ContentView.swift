import SwiftUI

struct ContentView: View {

    @StateObject private var camera = CameraModel()

    @State private var countdown = 0
    @State private var currentShot = 1
    @State private var totalShots = 3

    @State private var isCapturing = false
    @State private var showSettings = false
    @State private var isSessionActive = false

    var body: some View {

        ZStack {

            CameraView(camera: camera)
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack {

                Spacer()

                if countdown > 0 {

                    Text("\(countdown)")
                        .font(.system(size: 180, weight: .heavy))
                        .foregroundColor(.white)

                } else if isCapturing {

                    VStack(spacing: 20) {

                        Text("📸")
                            .font(.system(size: 80))

                        Text("CAPTURANDO...")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)

                        Text("Foto \(currentShot) de \(totalShots)")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.85))
                    }

                } else if !isSessionActive {

                    VStack(spacing: 30) {

                        Text("PHOTOBOOTH")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(.white)
                            .onLongPressGesture {

                                showSettings = true
                            }

                        Button(action: {

                            startSession()

                        }) {

                            Text("TOCA PARA COMENZAR")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(width: 350, height: 90)
                                .background(Color.white)
                                .cornerRadius(25)
                        }

                        Text("Modo actual: \(totalShots) fotos")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()
            }
            .padding()
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
                    .padding(.top, 20)
            }
            .padding()
        }
    }

    func startSession() {

        guard !isSessionActive else { return }

        isSessionActive = true

        currentShot = 1

        startCountdown()
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

            isCapturing = false

            if currentShot < totalShots {

                currentShot += 1

                startCountdown()

            } else {

                finishSession()
            }
        }
    }

    func finishSession() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            currentShot = 1
            isSessionActive = false
        }
    }
}

#Preview {

    ContentView()
}