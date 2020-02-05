//
//  AppDelegate+CLLocationManager.swift
//
//  Created by Aaron on 02/05/2020.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation
import CoreLocation

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        logger?.write("didEnterRegion: \(region.identifier)")
        
        DispatchQueue.global(qos: .background).async {
            self.logger?.write("Connecting to known devices...")
            Scanner.shared.connectToKnownPeripherals()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        logger?.write("didExitRegion: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            logger?.write("(\(Int.random(in: 0...9))) Found \(beacons.count) beacons")
        }
    }
    
    
    
}
