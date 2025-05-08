import UIKit

enum ClothingCategory: String, CaseIterable {
	case all = "All"
	case tops = "Tops"
	case sweaters = "Sweaters"
	case jeans = "Jeans"
	case skirts = "Skirts"
	case dresses = "Dresses"
	case jackets = "Jackets"
	case shoes = "Shoes"
	case accessories = "Accessories"

	var iconName: String {
		switch self {
		case .all: return "icon_all"
		case .tops: return "icon_tops"
		case .sweaters: return "icon_sweaters"
		case .jeans: return "icon_jeans"
		case .skirts: return "icon_skirts"
		case .dresses: return "icon_dresses"
		case .jackets: return "icon_jackets"
		case .shoes: return "icon_shoes"
		case .accessories: return "icon_accessories"
		}
	}
}

import FirebaseFirestore
import SDWebImage

class WardrobeCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let testUserId = "demoUser123"
	let categories = ClothingCategory.allCases.filter { $0 != .all }
	var previewImages: [ClothingCategory: String] = [:]

	var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Your Wardrobe"
		view.backgroundColor = .systemGroupedBackground
		setupCollectionView()
		loadCategoryPreviews()
	}

	func setupCollectionView() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 20
		layout.minimumInteritemSpacing = 20

		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
		collectionView.backgroundColor = .clear
		collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(CategoryCardCell.self, forCellWithReuseIdentifier: "CategoryCardCell")

		view.addSubview(collectionView)
	}

	func loadCategoryPreviews() {
		let db = Firestore.firestore()
		let group = DispatchGroup()

		for category in categories {
			group.enter()

			db.collection("wardrobeItems")
				.whereField("userId", isEqualTo: testUserId)
				.whereField("category", isEqualTo: category.rawValue)
				.limit(to: 1)
				.getDocuments { snapshot, error in
					if let doc = snapshot?.documents.first,
					   let url = doc.data()["imageUrl"] as? String {
						self.previewImages[category] = url
					} else {
						self.previewImages[category] = nil
					}
					group.leave()
				}
		}

		group.notify(queue: .main) {
			self.collectionView.reloadData()
		}
	}

	// MARK: - Collection View

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return categories.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCardCell", for: indexPath) as! CategoryCardCell
		let category = categories[indexPath.item]
		let previewUrl = previewImages[category]
		cell.configure(with: category, imageUrl: previewUrl)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let category = categories[indexPath.item]
		let filteredVC = FilteredWardrobeViewController(category: category)
		navigationController?.pushViewController(filteredVC, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let spacing: CGFloat = 20
		let columns: CGFloat = 2
		let totalSpacing = (columns - 1) * spacing
		let width = (collectionView.bounds.width - totalSpacing - 40) / columns
		return CGSize(width: width, height: width)
	}
}

