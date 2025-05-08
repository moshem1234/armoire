import UIKit
import FirebaseFirestore
import SDWebImage

class CreateOutfitViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let testUserId = "demoUser123"
	var wardrobeItems: [WardrobeItem] = []
	var selectedItemIds: Set<String> = []

	var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Create Outfit"
		view.backgroundColor = .white
		setupCollectionView()
		setupDoneButton()
		fetchWardrobeItems()
	}

	func setupCollectionView() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10

		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.allowsMultipleSelection = true
		collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")

		view.addSubview(collectionView)
	}

	func setupDoneButton() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveOutfit))
	}

	func fetchWardrobeItems() {
		let db = Firestore.firestore()
		db.collection("wardrobeItems")
			.whereField("userId", isEqualTo: testUserId)
			.getDocuments { snapshot, error in
				if let error = error {
					return
				}

				self.wardrobeItems = snapshot?.documents.compactMap { doc in
					let data = doc.data()
					guard let imageUrl = data["imageUrl"] as? String,
						  let name = data["name"] as? String,
						  let category = data["category"] as? String,
						  let userId = data["userId"] as? String else {
						return nil
					}
					return WardrobeItem(
						id: doc.documentID,
						category: category,
						createdAt: data["createdAt"] as? Timestamp,
						imageUrl: imageUrl,
						name: name,
						subcategory: data["subcategory"] as? String,
						tags: data["tags"] as? [String],
						userId: userId
					)
				} ?? []

				DispatchQueue.main.async {
					self.collectionView.reloadData()
				}
			}
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return wardrobeItems.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
		let item = wardrobeItems[indexPath.item]
		cell.configure(with: item.imageUrl)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let itemId = wardrobeItems[indexPath.item].id ?? ""
		selectedItemIds.insert(itemId)
	}

	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let itemId = wardrobeItems[indexPath.item].id ?? ""
		selectedItemIds.remove(itemId)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width - 30) / 2
		return CGSize(width: width, height: width)
	}

	// MARK: - Save Outfit

	@objc func saveOutfit() {
		guard !selectedItemIds.isEmpty else {
			let alert = UIAlertController(title: "No Items Selected", message: "Please select at least one item.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
			return
		}

		let prompt = UIAlertController(title: "New Outfit", message: "Enter a name for this outfit", preferredStyle: .alert)
		prompt.addTextField { $0.placeholder = "Outfit name" }
		prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		prompt.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
			let name = prompt.textFields?.first?.text ?? "Untitled Outfit"
			self.createOutfitDocument(name: name)
		}))
		present(prompt, animated: true)
	}

	func createOutfitDocument(name: String) {
		guard let firstItemId = selectedItemIds.first,
			  let firstItem = wardrobeItems.first(where: { $0.id == firstItemId }) else {
			return
		}

		let db = Firestore.firestore()
		let outfitData: [String: Any] = [
			"name": name,
			"description": "",
			"isDraft": false,
			"items": Array(selectedItemIds),
			"userId": testUserId,
			"createdAt": Timestamp(),
			"updatedAt": Timestamp(),
			"coverImageUrl": firstItem.imageUrl
		]

		db.collection("outfits").addDocument(data: outfitData) { error in
			if let error = error {
			} else {
				self.navigationController?.popToRootViewController(animated: true)
			}
		}
	}

}
