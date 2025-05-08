import UIKit
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

class AddWardrobeItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

	var categorySelectionHandler: ((String) -> Void)?
	let testUserId = "demoUser123"

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = "Add Wardrobe Item"

		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 24
		stack.alignment = .center
		stack.translatesAutoresizingMaskIntoConstraints = false

		let buttons = [
			createIconButton(title: "Take Photo", iconName: "camera.fill", action: #selector(openCamera)),
			createIconButton(title: "Choose from Library", iconName: "photo.on.rectangle", action: #selector(openLibrary)),
			createIconButton(title: "Paste from Clipboard", iconName: "doc.on.clipboard", action: #selector(pasteFromClipboard))
		]

		buttons.forEach { stack.addArrangedSubview($0) }

		view.addSubview(stack)

		NSLayoutConstraint.activate([
			stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
			stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
		])
	}

	private func createIconButton(title: String, iconName: String, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.baseBackgroundColor = .systemRed
		config.baseForegroundColor = .white
		config.cornerStyle = .medium
		config.image = UIImage(systemName: iconName)
		config.title = title
		config.imagePadding = 8
		config.imagePlacement = .top
		button.configuration = config
		button.addTarget(self, action: action, for: .touchUpInside)
		return button
	}


	@objc func openCamera() {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.sourceType = .camera
		present(picker, animated: true)
	}

	@objc func openLibrary() {
		var config = PHPickerConfiguration()
		config.selectionLimit = 1
		config.filter = .images
		let picker = PHPickerViewController(configuration: config)
		picker.delegate = self
		present(picker, animated: true)
	}

	@objc func pasteFromClipboard() {
		if let image = UIPasteboard.general.image {
			uploadImageToStorage(image) { url in
				if let imageUrl = url {
					self.promptForItemDetails(imageUrl: imageUrl)
				}
			}
		}
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		if let image = info[.originalImage] as? UIImage {
			uploadImageToStorage(image) { url in
				if let imageUrl = url {
					self.promptForItemDetails(imageUrl: imageUrl)
				}
			}
		}
	}

	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true)
		guard let result = results.first else { return }
		result.itemProvider.loadObject(ofClass: UIImage.self) { reading, _ in
			if let image = reading as? UIImage {
				self.uploadImageToStorage(image) { url in
					if let imageUrl = url {
						self.promptForItemDetails(imageUrl: imageUrl)
					}
				}
			}
		}
	}

	func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?) -> Void) {
		let ref = Storage.storage().reference().child("wardrobe/\(UUID().uuidString).jpg")
		guard let data = image.jpegData(compressionQuality: 0.8) else {
			completion(nil)
			return
		}
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		ref.putData(data, metadata: metadata) { _, error in
			if error != nil { completion(nil); return }
			ref.downloadURL { url, _ in
				completion(url?.absoluteString)
			}
		}
	}

	func promptForItemDetails(imageUrl: String) {
		let alert = UIAlertController(title: "Select Shelf", message: "\n\n\n\n\n", preferredStyle: .alert)
		alert.addTextField { $0.placeholder = "Name" }

		let picker = UIPickerView(frame: CGRect(x: 5, y: 50, width: 250, height: 100))
		picker.dataSource = self
		picker.delegate = self
		alert.view.addSubview(picker)

		var selectedCategory: String = ClothingCategory.allCases.first(where: { $0 != .all })?.rawValue ?? "Other"

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
			let name = alert.textFields?[0].text ?? "Untitled"
			self.saveItemToFirestore(with: imageUrl, name: name, category: selectedCategory)
		}))

		self.categorySelectionHandler = { selectedCategory = $0 }

		present(alert, animated: true)
	}

	func saveItemToFirestore(with imageUrl: String, name: String, category: String) {
		let data: [String: Any] = [
			"imageUrl": imageUrl,
			"name": name,
			"category": category,
			"userId": testUserId,
			"createdAt": Timestamp()
		]

		Firestore.firestore().collection("wardrobeItems").addDocument(data: data) { error in
			if error == nil {
				let alert = UIAlertController(title: "Added!", message: "Love the new piece !", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Add Another", style: .default))
				alert.addAction(UIAlertAction(title: "Home", style: .default, handler: { _ in
					self.navigationController?.popToRootViewController(animated: true)
				}))
				self.present(alert, animated: true)
			}
		}
	}
}

extension AddWardrobeItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		ClothingCategory.allCases.filter { $0 != .all }.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		ClothingCategory.allCases.filter { $0 != .all }[row].rawValue
	}
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let category = ClothingCategory.allCases.filter { $0 != .all }[row].rawValue
		categorySelectionHandler?(category)
	}
}

