import UIKit
import FirebaseFirestore
import SDWebImage

class FilteredWardrobeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let category: ClothingCategory
	var wardrobeItems: [WardrobeItem] = []
	var collectionView: UICollectionView!

	init(category: ClothingCategory) {
		self.category = category
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = category.rawValue
		view.backgroundColor = .white
		setupCollectionView()
		fetchItems()
	}

	func setupCollectionView() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10

		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		collectionView.backgroundColor = .white
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
		view.addSubview(collectionView)
	}

	func fetchItems() {
		let db = Firestore.firestore()
		let ref = db.collection("wardrobeItems")
			.whereField("userId", isEqualTo: "demoUser123")

		let query = ref.whereField("category", isEqualTo: category.rawValue)

		query.getDocuments { snapshot, error in
			if let error = error {
				return
			}
			self.wardrobeItems = snapshot?.documents.compactMap { doc in
				let data = doc.data()
				let url = data["imageUrl"] as? String ?? "missing"
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
		cell.configure(with: wardrobeItems[indexPath.item].imageUrl)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let spacing: CGFloat = 20
		let columns: CGFloat = 2
		let totalSpacing = (columns - 1) * spacing
		let width = (collectionView.bounds.width - totalSpacing - 40) / columns
		return CGSize(width: width, height: width)
	}
}
