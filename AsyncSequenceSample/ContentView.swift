//
//  ContentView.swift
//  AsyncSequenceSample
//
//  Created by Nicolas Ameghino on 1/30/26.
//

import SwiftUI

struct ContentView<VM: LocationViewModelProtocol>: View {

    @ObservedObject var locationViewModel: VM

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
    let viewModel = LocationCallbackViewModel()
    ContentView(locationViewModel: viewModel)
}

