//
//  BeaconScanner.swift
//  beacon-bt-poc
//
//  Created by Aaron on 2/5/20.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconScanner: NSObject {

    static var shared: BeaconScanner = BeaconScanner()
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
    }

    func configure(locationManagerDelegate delegate: CLLocationManagerDelegate) {
        logger?.write("Configuring Beacon Monitor...")
        locationManager.delegate = delegate
        self.locationManager.requestAlwaysAuthorization()
    }

    private let logger: Logger? = Constants.logger
    
    private var locationManager: CLLocationManager
    
    var isMonitoring: Bool {
        return locationManager.monitoredRegions.count > 0
    }
    
    private let beacons: [BeaconParameters] = [
               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 1, identifier: "B2"),
               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 2, identifier: "I2"),
               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 3, identifier: "M2"),
//               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 4, identifier: "B1"),
//               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 5, identifier: "I1"),
//               BeaconParameters(uuid: UUID(uuidString: "1F48215E-DFF1-41C1-8656-CD5D0E06A76D")!, major: 1, minor: 6, identifier: "M1"),
    ]
    
    func startScanning() {
        logger?.write("Starting to monitor for beacons. Currently Status: ")
        logStatus()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            logger?.write("Monitor for beacons authorized with status: \(status.description)")
            for beacon in beacons {
                startScanning(forBeacon: beacon)
            }
        } else {
            logger?.write("Not authorized to range/monitor for beacons, with status: \(status.description)")
        }
    }

    func logStatus() {
        logger?.write("Known Beacons:")
        for beacon in beacons {
            logger?.write("   \(beacon.shortDescription)")
        }
        
        if locationManager.monitoredRegions.count > 0 {
            logger?.write("Currently Monitoring: ")
            for region in locationManager.monitoredRegions {
                logger?.write("   \(region.identifier)")
            }
        } else {
            logger?.write("Not monitoring for any beacons")
        }
    }

    func isMonitoringForBeacon(with params: BeaconParameters) -> Bool {
        for region in locationManager.monitoredRegions {
            if let bregion = region as? CLBeaconRegion {
                if params.matches(region: bregion) {
                    return true
                }
            }
        }
        return false
    }
    
    func stopScanning() {
        logger?.write("Monitoring stopping...")
        
        for region in locationManager.monitoredRegions {
            logger?.write("   Stopping monitor for region: \(region.identifier)")
            locationManager.stopMonitoring(for: region)
        }
        
        logger?.write("Monitoring stopped.")
    }
    
    func startScanning(forBeacon beacon: BeaconParameters) {
        let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid, major: beacon.major, minor: beacon.minor, identifier: beacon.identifier ?? beacon.description)
        beaconRegion.notifyEntryStateOnDisplay = true
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            Constants.logger?.write("Monitoring for beacon: {uuid: \(beacon.uuid.uuidString.prefix(8)), major: \(beacon.major), minor: \(beacon.minor), identifier: \(beacon.identifier ?? "nil")}")
            locationManager.startMonitoring(for: beaconRegion)
        } else {
            Constants.logger?.write("Monitoring for beacons not available.")
        }
    }
    

}
