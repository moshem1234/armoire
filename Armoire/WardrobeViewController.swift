import UIKit
import FirebaseFirestore
import SDWebImage

class WardrobeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let testUserId = "demoUser123"
	var wardrobeItems: [WardrobeItem] = []

	var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Wardrobe"
		view.backgroundColor = .white

		setupCollectionView()
		fetchWardrobeItems()
	}

	func setupCollectionView() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
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
					guard let category = data["category"] as? String,
						  let imageUrl = data["imageUrl"] as? String,
						  let name = data["name"] as? String,
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

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width - 30) / 2
		return CGSize(width: width, height: width)
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = wardrobeItems[indexPath.item]
		let detailVC = WardrobeItemDetailViewController(item: item)
		navigationController?.pushViewController(detailVC, animated: true)
	}

}
