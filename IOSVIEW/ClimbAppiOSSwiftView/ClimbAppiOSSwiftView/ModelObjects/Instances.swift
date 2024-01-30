
import Foundation
struct Instances : Codable {
	let box : Box
	let mask_number : Int
    
	enum CodingKeys: String, CodingKey {

		case box = "box"
		case mask_number = "mask_number"
	}


}
