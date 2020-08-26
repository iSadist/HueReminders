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
    }
}
