import UIKit
import SDWebImage

class CategoryCardCell: UICollectionViewCell {
	private let imageView = UIImageView()
	private let label = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = .secondarySystemBackground
		contentView.layer.cornerRadius = 10
		contentView.clipsToBounds = true

		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.translatesAutoresizingMaskIntoConstraints = false

		label.font = .boldSystemFont(ofSize: 14)
		label.textColor = .label
		label.textAlignment = .center
		label.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
		label.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(imageView)
		contentView.addSubview(label)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			label.heightAnchor.constraint(equalToConstant: 30)
		])
	}

	func configure(with category: ClothingCategory, imageUrl: String?) {
		label.text = category.rawValue

		if let urlString = imageUrl {
			if let url = URL(string: urlString) {
				imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo")) { image, error, _, _ in
				}
			}
		} else {
			imageView.image = UIImage(systemName: "photo")
		}
	}


	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
