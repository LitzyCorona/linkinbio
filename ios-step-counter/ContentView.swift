import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pedometer: PedometerManager
    @State private var goalInput: String = ""

    private var progress: Double {
        guard pedometer.dailyGoal > 0 else { return 0 }
        return min(Double(pedometer.todaySteps) / Double(pedometer.dailyGoal), 1.0)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let error = pedometer.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                ProgressView(value: progress) {
                    HStack {
                        Text("Steps")
                        Spacer()
                        Text("\(pedometer.todaySteps) / \(pedometer.dailyGoal)")
                            .monospacedDigit()
                    }
                }
                .progressViewStyle(.linear)
                .tint(.blue)
                .padding(.horizontal)

                // Circular visualization
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .green]), center: .center), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("\(pedometer.todaySteps) steps")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                .frame(width: 220, height: 220)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Goal")
                        .font(.headline)

                    HStack(spacing: 12) {
                        TextField("Enter goal (steps)", text: $goalInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        Button("Set") {
                            if let value = Int(goalInput.filter({ $0.isNumber })) {
                                pedometer.setDailyGoal(value)
                                goalInput = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    HStack(spacing: 12) {
                        Button("5k") { pedometer.setDailyGoal(5_000) }
                            .buttonStyle(.bordered)
                        Button("8k") { pedometer.setDailyGoal(8_000) }
                            .buttonStyle(.bordered)
                        Button("10k") { pedometer.setDailyGoal(10_000) }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Step Counter")
            .onAppear {
                // Ensure updates start when view appears
                pedometer.startUpdates()
            }
            .onDisappear {
                pedometer.stopUpdates()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PedometerManager())
}
