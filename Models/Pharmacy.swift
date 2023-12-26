import Foundation


struct Pharmacy: Decodable {
    let name: String?
    let opening_hours: OpeningHours?
    let icon: String?
    let place_id: String?
    let rating: Double?
    let vicinity: String?
    let plus_code: PlusCode?
    let geometry: Geometry?
    let types: [String]?
    let isNobetci: Bool?
    let phone_number: String?
}

struct PlusCode: Codable {
    let compound_code: String
    let global_code: String
}

struct OpeningHours: Decodable {
    let open_now: Bool?
}

struct Photo: Decodable {
    let height: Int?
    let html_attributions: [String]?
    let photo_reference: String?
    let width: Int?
}

struct Geometry: Decodable {
    let location: _Location?
}

struct _Location: Decodable {
    let lat: Double?
    let lng: Double?
}

struct PharmacyResponse: Decodable {
    let results: [Pharmacy]
    let next_page_token: String?
}

