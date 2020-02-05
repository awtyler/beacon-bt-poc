//
//  CLAuthorizationStatus+description.swift
//  beacon-bt-poc
//
//  Created by Aaron on 2/5/20.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        default:
            return "Unknown"
        }
    }
}
