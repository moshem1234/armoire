import Foundation
import FirebaseFirestore

struct Outfit {
	let id: String?
	let coverImageUrl: String?
	let createdAt: Timestamp?
	let description: String?
	let isDraft: Bool
	let items: [String]?
	let name: String
	let updatedAt: Timestamp?
	let userId: String
}

struct WardrobeItem {
	let id: String?
	let category: String
	let createdAt: Timestamp?
	let imageUrl: String
	let name: String
	let subcategory: String?
	let tags: [String]?
	let userId: String
}

struct Collection {
	let id: String?
	let coverImageUrl: String?
	let createdAt: Timestamp?
	let description: String?
	let name: String
	let outfitIds: [String]?
	let userId: String
}
