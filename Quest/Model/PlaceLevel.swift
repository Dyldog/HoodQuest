//
//  PlaceLevel.swift
//  Quest
//
//  Created by Dylan Elliott on 20/5/2024.
//

import Foundation
import CoreLocation

enum PlaceLevel {
	case suburb
	case council
	case state
	case country
	
	var adminLevel: Int {
		switch self {
		case .suburb: 9
		case .council: 6
		case .state: 4
		case .country: 2
		}
	}
	
	var higherLevel: PlaceLevel {
		switch self {
		case .suburb: .council
		case .council: .state
		case .state: .country
		case .country: self
		}
	}
	
	var lowerLevel: PlaceLevel {
		switch self {
		case .suburb: self
		case .council: .suburb
		case .state: .council
		case .country: .state
		}
	}
	
	var canGoUp: Bool {
		higherLevel != self
	}
	
	var canGoDown: Bool {
		lowerLevel != self
	}
}

