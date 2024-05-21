//
//  PlaceDetailView.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import SwiftUI

struct PlaceDetailView: View {
	
	let place: Place
	@ObservedObject var visitManager: VisitManager
	@State var visited: Bool
	
	init(place: Place, visitManager: VisitManager) {
		self.place = place
		self.visitManager = visitManager
		self.visited = visitManager.hasVisitedPlace(place)
	}
	
	var body: some View {
		VStack {
			Text(place.name).font(.largeTitle)
			
			Button {
				visited ? visitManager.unvisitPlace(place) : visitManager.didVisitPlace(place)
				visited.toggle()
			} label: {
				if !visited {
					Text("Unvisited").font(.largeTitle)
				} else {
					HStack {
						Image(systemName: "checkmark")
							.imageScale(.large)
							.foregroundStyle(.green)
						Text("Visited")
							.font(.largeTitle)
					}
				}
			}
		}
	}
}

