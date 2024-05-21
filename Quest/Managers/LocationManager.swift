//
//  LocationManager.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
	private let locationManager: CLLocationManager
	
	var startUpdatingUponAuthorisation: Bool = true
	
	var currentLocationSubject: CurrentValueSubject<CLLocation?, Never> = .init(nil)
	var currentLocation: AnyPublisher<CLLocation?, Never> { currentLocationSubject.eraseToAnyPublisher() }

	override init() {
		locationManager = CLLocationManager()
		
		super.init()
		
		locationManager.delegate = self
		locationManager.distanceFilter = 10
	}
	
	func requestAuthorisation() {
		locationManager.requestWhenInUseAuthorization()
	}
	
	func startUpdating() {
		requestAuthorisation()
		currentLocationSubject.send(locationManager.location)
		locationManager.startUpdatingLocation()
	}
	
	// MARK: - CLLocationManagerDelegate
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if startUpdatingUponAuthorisation {
			startUpdating()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		currentLocationSubject.send(location)
	}
}
