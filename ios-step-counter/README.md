# iOS Step Counter (SwiftUI)

Simple step tracker with daily goals using CoreMotion's CMPedometer.

## Files
- StepCounterApp.swift — App entry point, injects `PedometerManager`.
- PedometerManager.swift — ObservableObject wrapping `CMPedometer` for live step updates and goal persistence.
- ContentView.swift — SwiftUI UI with linear and circular progress and goal controls.

## Xcode Setup
1. Open Xcode → File → New → Project… → iOS → App.
2. Product Name: StepCounter, Interface: SwiftUI, Language: Swift.
3. Save the project.
4. Replace the generated files with the ones in this folder (or add these alongside, adjusting the app struct name if needed).

### Capabilities and Permissions
- Add the following to your target Info (Info.plist):
  - Privacy - Motion Usage Description (`NSMotionUsageDescription`): "This app uses motion data to count your steps."
- No extra background modes required for basic step counting.

### Testing
- Run on a physical device for live pedometer data.
- On Simulator, CMPedometer returns unavailable; you will see the error message.

### Notes
- Goals are stored in `UserDefaults` under key `daily_step_goal`.
- `CMPedometer` aggregates steps from midnight; progress resets each day automatically.
