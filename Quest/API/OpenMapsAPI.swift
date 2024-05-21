//
//  OpenMapsAPIClient.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import Foundation
import CoreLocation
import Combine

struct OpenMapsAPI {
	
	func getArea(around location: CLLocation, at level: PlaceLevel) -> AnyPublisher<Area, Error> {
		return elementRequest("""
		is_in(\(location.coordinate.latitude),\(location.coordinate.longitude));
		area._[admin_level=\(level.adminLevel)];
		out;
		""").tryMap { (places: [Area]) in
			guard let place = places.first else { throw APIError.noResponse }
			return place
		}
		.eraseToAnyPublisher()
	}
	
	func getLocations(in locationID: Int, for type: PlaceType) -> AnyPublisher<[Place], Error> {
		return elementRequest("""
		area(\(locationID)) -> .a;
		(
			\(type.queryString(area: "area.a"))
		);
		out center;
		""")
	}
	
	func searchPlaces(_ query: String) -> AnyPublisher<String, Error> {
		return request("""
		nw[name~"\(query)"];
		out;
		""")
		.map { String(data: $0, encoding: .utf8) ?? "Couldn't map string from data "}
		.eraseToAnyPublisher()
	}
}

extension OpenMapsAPI {
	func elementRequest<T: Codable>(_ query: String)  -> AnyPublisher<[T], Error> {
		request(query)
			.decode(type: OpenMapsResponse<T>.self, decoder: JSONDecoder())
			.map { $0.elements }
			.mapError { $0.asAPIError }
			.eraseToAnyPublisher()
	}
	func request(_ query: String) -> AnyPublisher<Data, Error> {
		let url = URL(string: "https://overpass-api.de/api/interpreter")!
		var request = URLRequest(url: url)
		request.httpBody = """
		[out:json][timeout:90];
		\(query)
		""".data(using: .utf8)
		request.httpMethod = "POST"
		
		print(query)
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.map { data, response in
				print("Loaded")
//				print(String(data: data, encoding: .utf8))
				return data
			}
			.mapError { $0.asAPIError }
			.eraseToAnyPublisher()
	}
}
