//
//  LocationPublisherViewModel.swift
//  AsyncSequenceSample
//
//  Created by Nicolas Ameghino on 1/30/26.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation

class LocationPublisher: NSObject, CLLocationManagerDelegate {
    var locationPublisher: AnyPublisher<[CLLocation], Never> { _locationPublisher.eraseToAnyPublisher() }
    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> { _authorizationPublisher.eraseToAnyPublisher() }

    private var _authorizationPublisher = PassthroughSubject<CLAuthorizationStatus, Never>()
    private var _locationPublisher = PassthroughSubject<[CLLocation], Never>()

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _locationPublisher.send(locations)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        _authorizationPublisher.send(manager.authorizationStatus)
    }
}

class LocationPublisherViewModel: LocationViewModelProtocol, ObservableObject {
    private(set) var locationManager = CLLocationManager()
    private var locationDelegate = LocationPublisher()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocation?

    private var cancellables: Set<AnyCancellable> = .init()

    init() {
        locationManager.delegate = locationDelegate

        locationDelegate.locationPublisher.sink { locations in
            guard let location = locations.first else {
                print("unable to determine location")
                return
            }

            print("updated location: \(location.coordinate)")
            self.location = location
        }
        .store(in: &cancellables)

        locationDelegate.authorizationPublisher.sink { authStatus in
            self.authorizationStatus = authStatus
        }
        .store(in: &cancellables)
    }
}

struct LocationPublisherContentView: View {

    @StateObject var locationViewModel: LocationPublisherViewModel = .init()

    @ViewBuilder
    var needsAuthorizationView: some View {
        Button {
            locationViewModel.requestPermissionIfNeeded()
        } label: {
            VStack {
                Image(systemName: "location.slash")
                Text("Authorize")
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        VStack {
            Text("Current location")
            if let location = locationViewModel.location {
                Text(location.debugDescription)
            } else {
                Text("still working")
            }
        }
    }


    var body: some View {
        if !locationViewModel.isAuthorized {
            needsAuthorizationView
        } else {
            contentView
                .onAppear { locationViewModel.startUpdates() }
                .onDisappear { locationViewModel.stopUpdates() }
        }
    }
}

#Preview {
    LocationPublisherContentView()
}

