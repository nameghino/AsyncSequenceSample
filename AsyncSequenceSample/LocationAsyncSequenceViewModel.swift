//
//  LocationAsyncSequenceViewModel.swift
//  AsyncSequenceSample
//
//  Created by Nicolas Ameghino on 2/2/26.
//

import Foundation
import Combine
import CoreLocation

class LocationAsyncSequenceViewModel: LocationViewModelProtocol {
    var locationManager: CLLocationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private var locationManagerDelegate: CallbackLocationManagerDelegate = .init()

    private var _locationSequence: AsyncStream<CLLocation>
    private var _locationSequenceContinuation: AsyncStream<CLLocation>.Continuation
    var locationSequence: some AsyncSequence<CLLocation, Never> { _locationSequence }

    private var _locationAuthorizationSequence: AsyncStream<CLAuthorizationStatus>
    private var _locationAuthorizationSequenceContinuation: AsyncStream<CLAuthorizationStatus>.Continuation
    var locationAuthorizationSequence: some AsyncSequence<CLAuthorizationStatus, Never> { _locationAuthorizationSequence }

    init() {
        locationManager.delegate = locationManagerDelegate

        (_locationSequence, _locationSequenceContinuation) = AsyncStream<CLLocation>.makeStream()
        (_locationAuthorizationSequence, _locationAuthorizationSequenceContinuation) = AsyncStream<CLAuthorizationStatus>.makeStream()

        locationManagerDelegate.callback = { [weak self] locations in
            guard
                let self,
                let updated = locations.last
            else { return }
            self._locationSequenceContinuation.yield(updated)
            self._locationAuthorizationSequenceContinuation.yield(locationManager.authorizationStatus)
        }

        // start observation
        Task { [weak self] in
            guard let self else { return }
            for await item in self.locationSequence {
                self.location = item
            }
        }

        Task { [weak self] in
            guard let self else { return }
            for await item in self.locationAuthorizationSequence {
                self.authorizationStatus = item
            }
        }

        self.startUpdates()
    }

    deinit {
        _locationSequenceContinuation.finish()
        _locationAuthorizationSequenceContinuation.finish()
    }
}
