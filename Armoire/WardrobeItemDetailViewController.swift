import UIKit
import FirebaseFirestore
import SDWebImage

class WardrobeItemDetailViewController: UIViewController {

	let item: WardrobeItem
	var categorySelectionHandler: ((String) -> Void)?

	init(item: WardrobeItem) {
		self.item = item
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = item.name

		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.sd_setImage(with: URL(string: item.imageUrl), placeholderImage: UIImage(systemName: "photo"))

		let categoryLabel = UILabel()
		categoryLabel.text = "Category: \(item.category)"
		categoryLabel.translatesAutoresizingMaskIntoConstraints = false

		let editButton = UIButton(type: .system)
		editButton.setTitle("Edit Category", for: .normal)
		editButton.addTarget(self, action: #selector(editCategory), for: .touchUpInside)
		editButton.translatesAutoresizingMaskIntoConstraints = false

		let stack = UIStackView(arrangedSubviews: [imageView, categoryLabel, editButton])
		stack.axis = .vertical
		stack.spacing = 20
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = .center

		view.addSubview(stack)

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
		])
	}

	@objc func editCategory() {
		let alert = UIAlertController(title: "Edit Category", message: "\n\n\n\n\n", preferredStyle: .alert)

		let picker = UIPickerView(frame: CGRect(x: 5, y: 50, width: 250, height: 100))
		picker.dataSource = self
		picker.delegate = self
		alert.view.addSubview(picker)

		var selected = item.category

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
			if let id = self.item.id {
				Firestore.firestore().collection("wardrobeItems").document(id)
					.updateData(["category": selected]) { error in
					}
			}
		}))

		categorySelectionHandler = { selected = $0 }
		present(alert, animated: true)
	}
}

extension WardrobeItemDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		ClothingCategory.allCases.filter { $0 != .all }.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		ClothingCategory.allCases.filter { $0 != .all }[row].rawValue
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selected = ClothingCategory.allCases.filter { $0 != .all }[row].rawValue
		categorySelectionHandler?(selected)
	}
}
