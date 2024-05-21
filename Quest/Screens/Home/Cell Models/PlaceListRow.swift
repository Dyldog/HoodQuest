//
//  PlaceListRow.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation

struct PlaceListRow: Identifiable {
	var id: Int { place.id }
	
	let place: Place
	
	var name: String { place.tags.name }
	let distance: Double
}
