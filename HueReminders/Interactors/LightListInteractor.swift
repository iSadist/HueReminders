//
//  LightListInteractor.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-26.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

protocol LightListInteracting {
    func lightRowTapped(light: HueLightInfo, bridge: HueBridge, viewModel: LightListViewModel)
}

public class LightListInteractor: LightListInteracting {
    func lightRowTapped(light: HueLightInfo, bridge: HueBridge, viewModel: LightListViewModel) {
        let lightsRequest = HueAPI.getLights(bridge: bridge)
        HueAPI.toggleOnState(for: light, bridge)
        viewModel.fetchData(request: lightsRequest)
        // TODO: Solve this by triggering the publisher somehow.
        // Perhaps by making the fetch publisher subscribe to another publisher that is a toggle for "fetching lights"?
        // Check out some Combine tutorial to learn more.
    }
}
