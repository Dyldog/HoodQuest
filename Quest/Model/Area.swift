//
//  Area.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation

struct Area: Codable {
	let id: Int
	var name: String { tags.name }
	let tags: Tags
	
	struct Tags: Codable {
		let name: String
	}
}
