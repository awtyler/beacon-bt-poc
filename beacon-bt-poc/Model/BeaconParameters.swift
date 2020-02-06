//
//  BeaconParameters.swift
//  beacon-bt-poc
//
//  Created by Aaron on 2/5/20.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation
import CoreLocation

struct BeaconParameters: Codable {
    let uuid: UUID
    let major: CLBeaconMajorValue
    let minor: CLBeaconMinorValue
    let identifier: String?

    var description: String {
        return """
        {"uuid": "\(uuid.uuidString)", "major": "\(major)", "minor": "\(minor)", "identifier": "\(identifier ?? "nil")", }"
        """
    }

    var shortDescription: String {
        return """
        \(uuid.uuidString.prefix(8))-\(major)-\(minor)\(identifier != nil ? "-\(identifier!)" : "")
        """
    }
    
    func matches(region: CLBeaconRegion) -> Bool {
        
        let rMajor = region.major
        let rMinor = region.minor
        
        var rUuid: UUID? = nil
        if #available(iOS 13.0, *) {
            rUuid = region.uuid
        } else {
            rUuid = region.proximityUUID
        }
        
        if rUuid == uuid && rMajor == major as NSNumber? && rMinor == minor as NSNumber?  {
            return true
        }
        return false;
        
    }
}
