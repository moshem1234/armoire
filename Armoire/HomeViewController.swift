import UIKit

class HomeViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupLayout()
	}

	private func setupLayout() {
		let titleLabel = UILabel()
		titleLabel.text = "Your Wardrobe"
		titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
		titleLabel.textAlignment = .center
		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(titleLabel)

		let buttonConfigs: [(String, Selector?, Bool)] = [
			("Add Item", #selector(addWardrobeItem), true),
			("View Wardrobe", #selector(viewWardrobe), true),
			("Create Outfit", #selector(createOutfit), true),
			("View Outfits", #selector(viewOutfits), true),
			("Create Collection", nil, false), // Dormant
			("View Collections", #selector(viewCollections), false)
		]

		let gridStack = UIStackView()
		gridStack.axis = .vertical
		gridStack.spacing = 20
		gridStack.distribution = .fillEqually
		gridStack.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(gridStack)

		for i in stride(from: 0, to: buttonConfigs.count, by: 2) {
			let rowStack = UIStackView()
			rowStack.axis = .horizontal
			rowStack.spacing = 20
			rowStack.distribution = .fillEqually

			for j in 0..<2 {
				if i + j < buttonConfigs.count {
					let (title, selector, isEnabled) = buttonConfigs[i + j]
					let button = UIButton(type: .system)
					button.setTitle(title, for: .normal)
					button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
					button.setTitleColor(.white, for: .normal)
					button.backgroundColor = .systemRed
					button.layer.cornerRadius = 12
					button.isEnabled = isEnabled
					button.alpha = isEnabled ? 1.0 : 0.5
					button.translatesAutoresizingMaskIntoConstraints = false
					if let selector = selector {
						button.addTarget(self, action: selector, for: .touchUpInside)
					}
					NSLayoutConstraint.activate([
						button.heightAnchor.constraint(equalTo: button.widthAnchor)
					])
					rowStack.addArrangedSubview(button)
				}
			}

			gridStack.addArrangedSubview(rowStack)
		}

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

			gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
			gridStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			gridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])
	}

	@objc func addWardrobeItem() {
		navigationController?.pushViewController(AddWardrobeItemViewController(), animated: true)
	}
	
	@objc func viewWardrobe() {
		let vc = WardrobeCategoryViewController()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc func createOutfit() {
		navigationController?.pushViewController(CreateOutfitViewController(), animated: true)
	}
	
	@objc func viewOutfits() {
		navigationController?.pushViewController(OutfitsViewController(), animated: true)
	}
	
	@objc func viewCollections() {
		navigationController?.pushViewController(CollectionsViewController(), animated: true)
	}

}
