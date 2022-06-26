//
//  EndpointStatusTracker.swift
//  isItUp
//
//  Created by Paul van Woensel on 6/24/22.
//

import Foundation

class EndpointStatusTracker {
    private var endpoints: [Endpoint]
    private var healthStatus: [UUID:Bool] = [:]
    
    init(endpoints: [Endpoint]) {
        self.endpoints = endpoints
        for endpoint in endpoints {
            healthStatus[endpoint.id!] = true
        }
    }
    
    public func getStatus(by id: UUID) -> Bool {
        return healthStatus[id] ?? false
    }
    
    public func setStatus(for id: UUID, to status:Bool) -> Void {
        healthStatus[id] = status
    }
}
