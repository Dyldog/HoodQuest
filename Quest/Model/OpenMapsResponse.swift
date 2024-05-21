//
//  OpenMapsResponse.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation

struct OpenMapsResponse<T: Codable>: Codable {
	let elements: [T]
}
