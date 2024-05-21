//
//  VisitManager.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import Foundation
import Combine

class VisitManager: ObservableObject {
	
	let database: Database
	var visitsUpdated: AnyPublisher<Void, Never> { database.visitsUpdated }
	
	init(database: Database) {
		self.database = database
	}
	
	func hasVisitedPlace(_ place: Place) -> Bool {
		return database.visit(for: place.id) != nil
	}
	
	func didVisitPlace(_ place: Place) {
		Task { @MainActor in
			objectWillChange.send()
			await database.createVisit(.init(id: place.id))
		}
	}
	
	func unvisitPlace(_ place: Place) {
		Task { @MainActor in
			objectWillChange.send()
			await database.deleteVisit(.init(id: place.id))
		}
	}
}
