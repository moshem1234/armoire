import UIKit

class ImageCell: UICollectionViewCell {
	let imageView = UIImageView()
	let overlay = UIView()
	let checkmark = UIImageView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		imageView.translatesAutoresizingMaskIntoConstraints = false

		overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		overlay.isHidden = true
		overlay.layer.cornerRadius = 10
		overlay.translatesAutoresizingMaskIntoConstraints = false

		checkmark.image = UIImage(systemName: "checkmark.circle.fill")
		checkmark.tintColor = .white
		checkmark.translatesAutoresizingMaskIntoConstraints = false
		checkmark.isHidden = true

		contentView.addSubview(imageView)
		contentView.addSubview(overlay)
		overlay.addSubview(checkmark)

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			overlay.topAnchor.constraint(equalTo: contentView.topAnchor),
			overlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			overlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			overlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			checkmark.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -8),
			checkmark.bottomAnchor.constraint(equalTo: overlay.bottomAnchor, constant: -8),
			checkmark.widthAnchor.constraint(equalToConstant: 24),
			checkmark.heightAnchor.constraint(equalToConstant: 24)
		])
	}

	override var isSelected: Bool {
		didSet {
			overlay.isHidden = !isSelected
			checkmark.isHidden = !isSelected
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with urlString: String?) {
		if let urlString = urlString {
			if let url = URL(string: urlString) {
				imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo")) { image, error, _, _ in
				}
			}
		} else {
			imageView.image = UIImage(systemName: "photo")
		}
	}


}
