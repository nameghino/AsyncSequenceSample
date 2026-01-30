//
//  LocationCallbackViewModel.swift
//  AsyncSequenceSample
//
//  Created by Nicolas Ameghino on 1/30/26.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

class CallbackLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    typealias LocationsUpdateCallback = ([CLLocation]) -> Void

    var callback: LocationsUpdateCallback?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        callback?(locations)
    }
}

class LocationCallbackViewModel: LocationViewModelProtocol, ObservableObject {
    var locationManager = CLLocationManager()
    private var locationDelegate: CLLocationManagerDelegate

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined


    init() {
        let callbackLocationManagerDelegate = CallbackLocationManagerDelegate()
        self.locationDelegate = callbackLocationManagerDelegate
        callbackLocationManagerDelegate.callback = onLocationUpdate(_:)
        locationManager.delegate = callbackLocationManagerDelegate
    }

    private func onLocationUpdate(_ locations: [CLLocation]) {
        guard let location = locations.first else {
            print("unable to determine location")
            return
        }

        print("updated location: \(location.coordinate)")
        self.location = location
    }

    func requestPermissionIfNeeded() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

