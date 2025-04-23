//
//  ContentView.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import SwiftUI

struct ContentView: View {
	@StateObject var viewModel: ContentViewModel
	@State var detailPlace: Place?
	@State var showPlaceType: Bool = false
	@State var showDebug: Bool = false
	
	@State var unvisitedExpanded: Bool = true
	@State var visitedExpanded: Bool = true
	
	var body: some View {
		VStack(spacing: 0) {
            header
            bigCount
			typePicker
            placeList
                .padding(.top, 20)
		}
		.onAppear {
			viewModel.onAppear()
		}
		.sheet(item: $detailPlace) { detailPlace in
			PlaceDetailView(place: detailPlace, visitManager: viewModel.visitManager)
		}
		.sheet(isPresented: $showPlaceType) {
			NavigationStack {
				PlaceTypesList()
			}
		}
		.sheet(isPresented: $showDebug) {
			PlaceDebugView()
		}
	}
    
    private var header: some View {
        ZStack {
            HStack {
                Button(systemName: "dice.fill") {
                    detailPlace = viewModel.unvisitedPlaces.randomElement()?.place
                }
                .padding()
                
                Spacer()
                Button {
                    showDebug = true
                } label: {
                    Image(systemName: "ant.fill")
                }
                .padding()
            }
            HStack {
                Button {
                    viewModel.level = viewModel.level.higherLevel
                } label: {
                    Image(systemName: "arrow.up")
                }
                .disabled(viewModel.level.canGoUp == false)
                
                Text("\(viewModel.placeTitle ?? "Finding location...")").bold()
                
                Button {
                    viewModel.level = viewModel.level.lowerLevel
                } label: {
                    Image(systemName: "arrow.down")
                }
                .disabled(viewModel.level.canGoDown == false)
            }
        }
    }
    
    @ViewBuilder
    private var bigCount: some View {
        if viewModel.totalPlaces > 0 {
            Text("\(viewModel.visitedPlaces.count)/\(viewModel.totalPlaces)")
                .font(.system(size: 120))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding(.horizontal)
        }
    }
    
    private var typePicker: some View {
        HStack {
            Picker("Type", selection: $viewModel.selectedPlaceTypeID) {
                ForEach(viewModel.placeTypes) {
                    Text($0.title).tag($0.id)
                }
            }
            
            Button {
                showPlaceType = true
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    @ViewBuilder
    private var placeList: some View {
        VStack {
            if let error = viewModel.error {
                listBackground {
                    Text(error)
                        .bold()
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20))
                        .padding()
                }
            } else if viewModel.loading {
                listBackground {
                    ProgressView().progressViewStyle(.circular)
                }
            } else {
                populatedList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func listBackground(_ content: () -> some View) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor: .systemGroupedBackground))
            content()
        }
        .ignoresSafeArea()
    }
    
    private var populatedList: some View {
        List {
            Section("Unvisited", isExpanded: $unvisitedExpanded) {
                ForEach(viewModel.unvisitedPlaces) { place in
                    view(for: place)
                }
            }
            
            Section("Visited", isExpanded: $visitedExpanded) {
                ForEach(viewModel.visitedPlaces) { place in
                    HStack {
                        Image(systemName: "checkmark")
                        view(for: place)
                    }
                }
            }
        }
    }
	
	private func view(for row: PlaceListRow) -> some View {
		Button {
			detailPlace = row.place
		} label: {
			HStack {
				Text(row.name)
				Spacer()
				Text(title(forDistance: row.distance))
					.foregroundStyle(.gray)
					.font(.body)
			}
			.buttonStyle(.plain)
		}
		.buttonStyle(.plain)
	}
	
	private func title(forDistance distance: Double) -> String {
		switch distance {
		case 0 ..< 1000: "\(Int(distance)) m"
		default: "\(String(format: "%.02f", distance / 1000)) km"
		}
	}
}

#Preview {
	ContentView(viewModel: .init(visitManager: .init(database: try! .init())))
}
