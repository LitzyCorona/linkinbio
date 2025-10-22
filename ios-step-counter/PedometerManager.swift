import Foundation
import CoreMotion
import Combine

final class PedometerManager: ObservableObject {
    private let pedometer = CMPedometer()
    private var cancellables = Set<AnyCancellable>()

    @Published var todaySteps: Int = 0
    @Published var dailyGoal: Int = 8000
    @Published var isAuthorized: Bool = true
    @Published var errorMessage: String? = nil

    private let goalKey = "daily_step_goal"

    init() {
        loadGoal()
        requestAuthorizationIfNeeded()
        startUpdates()
    }

    func requestAuthorizationIfNeeded() {
        // CMPedometer has implicit authorization prompts when querying.
        // Check device capability first.
        guard CMPedometer.isStepCountingAvailable() else {
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = false
                self?.errorMessage = "Step counting not available on this device."
            }
            return
        }
        isAuthorized = true
    }

    func setDailyGoal(_ newGoal: Int) {
        let clamped = max(1000, min(newGoal, 100_000))
        dailyGoal = clamped
        UserDefaults.standard.set(clamped, forKey: goalKey)
    }

    private func loadGoal() {
        let saved = UserDefaults.standard.integer(forKey: goalKey)
        if saved > 0 { dailyGoal = saved }
    }

    func startUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }

        // Reset today's steps and begin live updates from midnight
        todaySteps = 0
        errorMessage = nil

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        // One-shot query to get steps since start of day
        pedometer.queryPedometerData(from: startOfDay, to: Date()) { [weak self] data, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.todaySteps = data?.numberOfSteps.intValue ?? 0
            }
        }

        // Live updates
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.todaySteps = data?.numberOfSteps.intValue ?? self?.todaySteps ?? 0
            }
        }
    }

    func stopUpdates() {
        pedometer.stopUpdates()
    }
}
