import SwiftUI

struct HomeViewControllerWrapper: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UIViewController {
		let homeVC = HomeViewController()
		return UINavigationController(rootViewController: homeVC)
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
	}
}
