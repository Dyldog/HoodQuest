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
    @State var loading: Bool = false
	
	var body: some View {
		VStack {
			TextField("Search", text: $searchText).multilineTextAlignment(.center)
            
            if loading {
                loadingView
            } else {
                resultsView
            }
		}
		.padding()
		.onChange(of: searchText) { _, value in
            loading = true
			cancellable?.cancel()
			cancellable = api.searchPlaces(value)
				.sink {
					response = $0
                    loading = false
				} error: {
					response = "Error: \($0.localizedDescription)"
                    loading = false
				}

		}
	}
    
    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView().progressViewStyle(.circular)
            Spacer()
        }
    }
    
    var resultsView: some View {
        ScrollView {
            Text(response)
        }
    }
}
