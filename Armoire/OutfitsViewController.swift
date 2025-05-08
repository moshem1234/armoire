import UIKit
import FirebaseFirestore
import SDWebImage

class OutfitsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	let testUserId = "demoUser123"
	var outfits: [Outfit] = []

	var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Outfits"
		view.backgroundColor = .white

		setupCollectionView()
		fetchOutfits()
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
		collectionView.register(OutfitImageCell.self, forCellWithReuseIdentifier: "OutfitImageCell")

		view.addSubview(collectionView)
	}

	func fetchOutfits() {
		let db = Firestore.firestore()
		db.collection("outfits")
			.whereField("userId", isEqualTo: testUserId)
			.getDocuments { snapshot, error in
				if let error = error {
					return
				}
				self.outfits = snapshot?.documents.compactMap { doc in
					let data = doc.data()
					guard let name = data["name"] as? String,
						  let userId = data["userId"] as? String,
						  let isDraft = data["isDraft"] as? Bool else {
						return nil
					}

					return Outfit(
						id: doc.documentID,
						coverImageUrl: data["coverImageUrl"] as? String,
						createdAt: data["createdAt"] as? Timestamp,
						description: data["description"] as? String,
						isDraft: isDraft,
						items: data["items"] as? [String],
						name: name,
						updatedAt: data["updatedAt"] as? Timestamp,
						userId: userId
					)
				} ?? []

				DispatchQueue.main.async {
					self.collectionView.reloadData()
				}
			}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return outfits.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutfitImageCell", for: indexPath) as! OutfitImageCell
		let outfit = outfits[indexPath.item]
		cell.configure(with: outfit.coverImageUrl)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.bounds.width - 30) / 2
		return CGSize(width: width, height: width)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let outfit = outfits[indexPath.item]
		let detailVC = OutfitDetailViewController(outfit: outfit)
		navigationController?.pushViewController(detailVC, animated: true)
	}
}

class OutfitImageCell: UICollectionViewCell {
	let imageView = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(imageView)
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with imageUrl: String?) {
		if let urlStr = imageUrl, let url = URL(string: urlStr) {
			imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
		} else {
			imageView.image = UIImage(systemName: "photo")
		}
	}
}
