//
//  PlaceDebugView.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import SwiftUI
import Combine

struct PlaceDebugView: View {
	let api = OpenMapsAPI()
	@State var searchText: String = ""
	@State var response: String = ""
	@State var cancellable: Cancellable?
	
	var body: some View {
		VStack {
			TextField("Search", text: $searchText).multilineTextAlignment(.center)
			ScrollView {
				Text(response)
			}
		}
		.padding()
		.onChange(of: searchText) { _, value in
			cancellable?.cancel()
			cancellable = api.searchPlaces(value)
				.sink {
					response = $0
				} error: {
					response = "Error: \($0.localizedDescription)"
				}

		}
	}
}
