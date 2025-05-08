import SwiftUI
import FirebaseCore

@main
struct ArmoireApp: App {
	init() {
		configureFirebase()
	}
    var body: some Scene {
        WindowGroup {
            HomeViewControllerWrapper()
        }
    }
	private func configureFirebase() {
		if FirebaseApp.app() == nil {
			FirebaseApp.configure()
		}
	}
}
