//
//  OpenMapsAPIClient.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import Foundation

enum APIError: Error, LocalizedError {
	case requestError
	case serverError
	case noResponse
	case responseNotString
	case couldntDecode(DecodingError)
	case unknown
	
	var errorDescription: String? {
		switch self {
		case .requestError: "Request error"
		case .serverError: "Server error"
		case .noResponse: "No response data"
		case .responseNotString: "Response data was not a string"
		case let .couldntDecode(error): "Coudln't decode: \(error.localizedDescription)"
		case .unknown: "Unknown error"
		}
	}
}

struct Place: Codable, Identifiable {
	enum CodingKeys: String, CodingKey {
		case latitude = "lat"
		case longitude = "lon"
		case id
		case tags
	}
	
	let latitude: Double
	let longitude: Double
	let id: Int
	let tags: Tags
	
	var name: String { tags.name }
	
	struct Tags: Codable {
		let name: String
	}
}

struct OpenMapsResponse: Codable {
	let elements: [Place]
}

struct OpenMapsAPI {
	func getLocations(in suburb: String, for type: PlaceType, completion: @escaping (Result<[Place], APIError>) -> Void) {
		let url = URL(string: "https://overpass-api.de/api/interpreter")!
		var request = URLRequest(url: url)
		request.httpBody = """
		[out:json]
		[timeout:90]
		;
		area[name="\(suburb)"][place=suburb];
		node\(type.queryString)[name~".+"](area);
		out;
		""".data(using: .utf8)
		request.httpMethod = "POST"
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error {
				guard let error = error as? URLError else { return completion(.failure(.unknown))}
				switch error.code.rawValue {
				case 400 ..< 500: completion(.failure(.requestError))
				case 500 ..< 600: completion(.failure(.serverError))
				default: completion(.failure(.unknown))
				}
				return
			}
			
			guard let data else { return completion(.failure(.noResponse)) }
				
			do {
				let places = try JSONDecoder().decode(OpenMapsResponse.self, from: data)
				completion(.success(places.elements))
			} catch {
				switch error {
				case let decodingError as DecodingError:
					completion(.failure(.couldntDecode(decodingError)))
				default:
					completion(.failure(.unknown))
				}
				
				if let string = String(data: data, encoding: .utf8) {
					print(string)
				}
			}
		}.resume()
	}
}
