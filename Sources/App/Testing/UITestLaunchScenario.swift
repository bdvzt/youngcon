import Foundation

enum UITestLaunchScenario {
    case none
    case map

    static var current: UITestLaunchScenario {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("--uitesting-map") {
            return .map
        }

        return .none
    }
}
