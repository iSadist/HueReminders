//
//  ConnectView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-13.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import Combine
import CoreGraphics

struct HueError: Codable {
    var type: Int
    var address: String
    var description: String
}

struct HueSuccess: Codable {
    var username: String
}

struct HueConnectResponse: Codable {
    var success: HueSuccess?
    var error: HueError?
}

struct ConnectView: View {
    @ObservedObject var connectViewModel = ConnectViewModel()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>

    private var cancellables = Set<AnyCancellable>()

    init() {
        connectViewModel.validIPAddressPublisher
            .combineLatest(connectViewModel.validBridgeNamePublisher)
            .map { $0 && $1 }
            .receive(on: RunLoop.main)
            .assign(to: \.canConnect, on: connectViewModel)
            .store(in: &cancellables)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 25) {
                Text("Before you can start to set reminders you need to connect to a Hue Bridge")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                Text(connectViewModel.informationMessage)
                    .font(.subheadline)

                if connectViewModel.isLoading {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                } else {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .hidden()
                }

                TextField("Bridge name", text: $connectViewModel.bridgeName)
                TextField("Hue Bridge address", text: $connectViewModel.ipAddress)
                Spacer()
                Button(action: {
                    self.connectViewModel.connect(request: HueAPI.connect(to: self.connectViewModel.ipAddress))
                }) {
                    Text("Connect")
                }
                .disabled(!self.connectViewModel.canConnect)
            }
            .padding(25)
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
