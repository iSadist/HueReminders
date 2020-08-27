//
//  CalendarConfigurationInteractor.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-27.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

protocol CalendarConfigurationInteracting {
    func lightRowTapped(light: HueLightInfo, bridge: HueBridge, viewModel: LightListViewModel)
}

class CalendarConfigurationInterator: CalendarConfigurationInteracting {
    func lightRowTapped(light: HueLightInfo, bridge: HueBridge, viewModel: LightListViewModel) {

    }
}
