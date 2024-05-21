//
//  Place.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation
import CoreLocation

struct Place: Codable, Identifiable {
	enum CodingKeys: String, CodingKey {
		case lat
		case lon
		case center
		case id
		case tags
	}
	
	private let lat: Double?
	private let lon: Double?
	private let center: Point?
	
	let id: Int
	let tags: Tags
	
	var location: CLLocation? {
		if let center {
			return .init(latitude: center.lat, longitude: center.lon)
		} else if let lat, let lon {
			return .init(latitude: lat, longitude: lon)
		} else {
			return nil
		}
	}
	
	var name: String { tags.name }
	
	struct Tags: Codable {
		let name: String
	}
	
	struct Point: Codable {
		let lat: Double
		let lon: Double
	}
}
