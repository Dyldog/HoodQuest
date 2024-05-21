//
//  ContentViewModel.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation
import Combine
import CoreLocation
import DylKit
import SwiftUI

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
	
	@ObservedObject var visitManager: VisitManager
	let api = OpenMapsAPI()
	let locationManager = LocationManager()
	
	@Published private var currentLocation: CLLocation?
	@Published private var area: Area?
	@Published private var places: [Place] = []
	@Published var level: PlaceLevel = .suburb
	
	var placeTitle: String? { area?.name ?? "Loading..." }
	@Published var unvisitedPlaces: [PlaceListRow] = []
	@Published var visitedPlaces: [PlaceListRow] = []
	
	var totalPlaces: Int { places.count }
	
	var placeTypes: [PlaceType] { PlaceType.all }
	var selectedPlaceTypeID: UUID {
		get { PlaceType.selected }
		set {
			objectWillChange.send()
			PlaceType.selected = newValue
			loadPlaces()
		}
	}
	
	var selectedPlaceType: PlaceType? {
		placeTypes.first(where: { $0.id == selectedPlaceTypeID })
	}
	
	private var cancellables: Set<AnyCancellable> = .init()
	private var areaCancellable: AnyCancellable?
	private var placesCancellable: AnyCancellable?
	
	let debugLocation: CLLocation? = nil // .init(latitude: -37.80580, longitude: 144.97523)
	
	init(visitManager: VisitManager) {
		self.visitManager = visitManager
		self.locationManager.startUpdating()
		super.init()
		
		visitManager.visitsUpdated
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				onMain { self?.refreshPlaces() }
			}.store(in: &cancellables)
		
		if debugLocation == nil {
			// Store location from location manager
			locationManager.currentLocation
				.receive(on: RunLoop.main)
				.sink { [weak self] location in
					guard let self else { return }
					currentLocation = location
				}
				.store(in: &cancellables)
		} else {
			currentLocation = debugLocation
		}
		
		// Refresh places when location updated
		$currentLocation
			.receive(on: RunLoop.main)
			.sink { [weak self] location in
				guard let self else { return }
				if !places.isEmpty { refreshPlaces() }
			}
			.store(in: &cancellables)
		
		// Get area when location updated
		$currentLocation
			.compactMap { return $0 }
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.loadArea()
			}
			.store(in: &cancellables)
		
		// Get area when level updated
		$level
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.loadArea()
			}
			.store(in: &cancellables)
		
		// Load places when area updated
		$area
			.drop { [weak self] area in area == nil || self?.selectedPlaceType == nil }
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.loadPlaces()
			}
			.store(in: &cancellables)
	}
	
	func onAppear() {
		locationManager.startUpdating()
	}
	
	private func handleResult<T>(_ result: Result<T, Error>, handle: @escaping (T) -> Void) {
		switch result {
		case let .success(value): onMain { handle(value) }
		case let .failure(error): handleError(error)
		}
	}
	
	private func handleError(_ error: Error) {
		print(error)
	}
	
	private func loadArea() {
		guard let currentLocation else { return }
		
		areaCancellable?.cancel()
		
		areaCancellable = self.api.getArea(around: currentLocation, at: self.level)
			.asResult()
			.sink { [weak self] in
				guard let self else { return }
				self.handleResult($0) { area in
					self.area = area
				}
			}
	}
	
	private func loadPlaces() {
		guard let area, let selectedPlaceType else { return }
		
		placesCancellable?.cancel()
		
		placesCancellable = api.getLocations(in: area.id, for: selectedPlaceType)
			.asResult()
			.sink { [weak self] in
				guard let self else { return }
				handleResult($0) { places in
					self.places = places
					self.refreshPlaces()
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
		guard let currentLocation, let place = place.location else { return -1 }
		return currentLocation.distance(from: place)
	}
}
