//
//  ContentView.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import SwiftUI
import Combine
import CoreLocation
import DylKit

struct PlaceListRow: Identifiable {
	var id: Int { place.id }
	
	let place: Place
	
	var name: String { place.tags.name }
	let distance: Double
}

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
	
	@ObservedObject var visitManager: VisitManager
	let api = OpenMapsAPI()
	let locationManager = CLLocationManager()
	@Published private var places: [Place] = []
	
	private var cancellables: Set<AnyCancellable> = .init()
	
	@Published var currentLocation: CLLocation?
	@Published var currentSuburb: String?
	
	@Published var unvisitedPlaces: [PlaceListRow] = []
	@Published var visitedPlaces: [PlaceListRow] = []
	
	var totalPlaces: Int { places.count }
	
	var placeTypes: [PlaceType] { PlaceType.all }
	var selectedPlaceTypeID: UUID {
		get { PlaceType.selected }
		set {
			objectWillChange.send()
			PlaceType.selected = newValue
			if let currentSuburb {
				loadPlaces(in: currentSuburb)
			}
		}
	}
	var selectedPlaceType: PlaceType? {
		placeTypes.first(where: { $0.id == selectedPlaceTypeID })
	}
	
	init(visitManager: VisitManager) {
		self.visitManager = visitManager
		self.locationManager.requestWhenInUseAuthorization()
		super.init()
		
		self.visitManager.visitsUpdated.sink { [weak self] _ in
			DispatchQueue.main.async { self?.refreshPlaces() }
		}.store(in: &cancellables)
		
		locationManager.delegate = self
		locationManager.distanceFilter = 3
	}
	
	func onAppear() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		locationManager.startUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
		self.currentLocation = location
		
		if !places.isEmpty { refreshPlaces() }
		
		getSuburb(location) { suburb in
			if self.currentSuburb != suburb {
				self.currentSuburb = suburb
				self.loadPlaces(in: suburb)
			} else {
				self.refreshPlaces()
			}
		}
		
	}
	
	private func getSuburb(_ location: CLLocation, completion: @escaping (String) -> Void) {
		CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
			guard let placemark = placemarks?.first,
				  let suburb = placemark.locality else { return }
			completion(suburb)
		}
	}
	
	private func loadPlaces(in suburb: String) {
		guard let selectedPlaceType else { return }
		api.getLocations(in: suburb, for: selectedPlaceType) { result in
			switch result {
			case let .success(places):
				DispatchQueue.main.async { [weak self] in
					self?.places = places
					self?.refreshPlaces()
				}
			case let .failure(error):
				print(error.localizedDescription)
			}
		}
	}
	
	private func refreshPlaces() {
		func makeList(from places: [Place]) -> [PlaceListRow] {
			return places
				.sorted(by: { distance(from: $0) < distance(from: $1 )})
				.map { .init(place: $0, distance: distance(from: $0)) }
			
		}
		
		unvisitedPlaces = makeList(from: places.filter { visitManager.hasVisitedPlace($0) == false })
		visitedPlaces = makeList(from: places.filter { visitManager.hasVisitedPlace($0) })
	}
	
	private func distance(from place: Place) -> Double {
		guard let currentLocation else { return -1 }
		return currentLocation.distance(from: .init(latitude: place.latitude, longitude: place.longitude))
	}
}


struct ContentView: View {
	@StateObject var viewModel: ContentViewModel
	@State var detailPlace: Place?
	@State var showPlaceType: Bool = false
	
	var body: some View {
		VStack(spacing: 0) {
			Text("\(viewModel.currentSuburb ?? "Finding suburb...")").bold()
			if viewModel.totalPlaces > 0 {
				Text("\(viewModel.visitedPlaces.count)/\(viewModel.totalPlaces)")
					.font(.system(size: 120))
					.fixedSize()
					.minimumScaleFactor(0.1)
			}
			
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

			List {
				ForEach(viewModel.unvisitedPlaces) { place in
					view(for: place)
				}
				
				ForEach(viewModel.visitedPlaces) { place in
					HStack {
						Image(systemName: "checkmark")
						view(for: place)
					}
				}
			}
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
