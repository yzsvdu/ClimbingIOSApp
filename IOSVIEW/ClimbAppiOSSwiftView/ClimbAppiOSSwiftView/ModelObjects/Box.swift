import Foundation
struct Box : Codable {
	let x_min : Double
	let y_min : Double
	let x_max : Double
	let y_max : Double

	enum CodingKeys: String, CodingKey {

		case x_min = "x_min"
		case y_min = "y_min"
		case x_max = "x_max"
		case y_max = "y_max"
	}

}
