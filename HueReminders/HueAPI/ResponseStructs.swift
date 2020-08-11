//
//  ResponseStructs.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import SwiftUI

struct HueLightInfo: Comparable, Identifiable, Hashable {
    static func < (lhs: HueLightInfo, rhs: HueLightInfo) -> Bool {
        lhs.name < rhs.name
    }

    var id: String
    var name: String
    var on: Bool
    var color: Color
}

struct HueLightResponse: Decodable {
    var state: HueLightState
//    var swupdate: Any
    var type: String
    var name: String
    var modelid: String
    var manufacturername: String
    var productname: String
//    var capabilities: Any
//    var config: Any
    var uniqueid: String
    var swversion: String
}

struct HueLightState: Decodable {
    var on: Bool
    var bri: Int
    var hue: Int
    var sat: Int
    var effect: String
    var xy: [Double]
    var ct: Int
    var alert: String
    var colormode: String
    var mode: String
    var reachable: Bool
}

struct HueSchedulesResponse: Decodable {
    var success: HueScheduleSuccess?
    var error: HueScheduleError?
}

struct HueScheduleSuccess: Decodable {
    var id: String
}

struct HueScheduleError: Decodable {
    var type: Int
    var address: String
    var description: String
}
