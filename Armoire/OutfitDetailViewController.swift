import UIKit
import FirebaseFirestore
import SDWebImage

class OutfitDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let outfit: Outfit
	var wardrobeItems: [WardrobeItem] = []

	var collectionView: UICollectionView!

	init(outfit: Outfit) {
		self.outfit = outfit
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = outfit.name
		view.backgroundColor = .white
		setupUI()
		fetchWardrobeItems()
	}

	func setupUI() {
		let coverImageView = UIImageView()
		coverImageView.contentMode = .scaleAspectFill
		coverImageView.clipsToBounds = true
		coverImageView.translatesAutoresizingMaskIntoConstraints = false
		if let urlStr = outfit.coverImageUrl, let url = URL(string: urlStr) {
			coverImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
		}

		let descriptionLabel = UILabel()
		descriptionLabel.text = outfit.description ?? ""
		descriptionLabel.font = .systemFont(ofSize: 14)
		descriptionLabel.textColor = .darkGray
		descriptionLabel.numberOfLines = 0
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10

		collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
		collectionView.backgroundColor = .white
		collectionView.translatesAutoresizingMaskIntoConstraints = false

		let stack = UIStackView(arrangedSubviews: [coverImageView, descriptionLabel, collectionView])
		stack.axis = .vertical
		stack.spacing = 20
		stack.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(stack)

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor, multiplier: 0.75)
		])
	}

	func fetchWardrobeItems() {
		let db = Firestore.firestore()
		let itemIds = outfit.items ?? []

		guard !itemIds.isEmpty else { return }

		db.collection("wardrobeItems")
			.whereField(FieldPath.documentID(), in: itemIds)
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
		cell.configure(with: wardrobeItems[indexPath.item].imageUrl)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width - 30) / 2
		return CGSize(width: width, height: width)
	}
}
