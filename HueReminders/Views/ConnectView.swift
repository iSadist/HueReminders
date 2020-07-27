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

    private var cancellables = Set<AnyCancellable>()

    init() {
        connectViewModel.connectedPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isConnected, on: connectViewModel)
            .store(in: &cancellables)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 15) {
                Image("hue_logo")
                    .scaleEffect(0.5)
                    .edgesIgnoringSafeArea(.top)
                    .padding(EdgeInsets(top: -50, leading: 0, bottom: -100, trailing: 0))

                Text("Before you can start to set reminders you need to connect to a Hue Bridge")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
                
                Text(connectViewModel.informationMessage)

                if connectViewModel.isAnimating {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                } else {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .hidden()
                }

                TextField("Hue Bridge address", text: $connectViewModel.ipAddress)
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))

                Button(action: {
                    self.connectViewModel.isAnimating = true
                    if let url = URL(string: "http://\(self.connectViewModel.ipAddress)/api") {
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"

                        let parameterDictionary = ["devicetype": "huereminders"]
                        let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
                        request.httpBody = httpBody

                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            // TODO: State should not be updated on the main thread
                            self.connectViewModel.isAnimating = false
                            guard let data = data else {
                                self.connectViewModel.informationMessage = "Could not connect"
                                return
                            }
                            if let dataResponses = try? JSONDecoder().decode([HueConnectResponse].self, from: data) {
                                let firstResponse = dataResponses.first

                                if let error = firstResponse?.error {
                                    switch error.type {
                                    case 101:
                                        self.connectViewModel.informationMessage = "The link button was not pressed"
                                    default:
                                        self.connectViewModel.informationMessage = "Unknown error in response"
                                    }
                                } else if let username = firstResponse?.success?.username {
                                    self.connectViewModel.usernameID = username
                                    self.connectViewModel.isConnected = true
                                    self.connectViewModel.informationMessage = "Connection successful"
                                }
                            } else {
                                self.connectViewModel.informationMessage = "Could not connect"
                            }
                        }
                        task.resume()
                    } else {
                        self.connectViewModel.informationMessage = "Not a valid ip address"
                    }
                }) {
                    Text("Connect")
                }

                if connectViewModel.isConnected { // TODO: Remove this eventually. Should just save the username in the data model
                    Text("Username")
                    TextField("Username", text: $connectViewModel.usernameID)

                    Button(action: {
                        print("Continue")

//                        let rem = HueReminders

                    }) {
                        Text("Next")
                    }
                }
                Spacer()
            }
        }.navigationBarTitle("Connect")
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
