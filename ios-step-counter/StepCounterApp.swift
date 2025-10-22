import SwiftUI

@main
struct StepCounterApp: App {
    @StateObject private var pedometerManager = PedometerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pedometerManager)
        }
    }
}
