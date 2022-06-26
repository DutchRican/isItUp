//
//  UrlCheck.swift
//  isItUp
//
//  Created by Paul van Woensel on 6/24/22.
//

import Foundation
import SwiftUI

@MainActor
func checkUrl(for endpoint: Endpoint) async throws -> Bool {
    do {
        var request = URLRequest(url: URL(string: endpoint.url!)!)
        request.httpMethod = endpoint.requestType
        for header in endpoint.headers ?? [] {
            print("Setting header to: \((header as! Header).key_value!) -- \((header as! Header).key_name!))")
            request.setValue((header as! Header).key_value, forHTTPHeaderField: (header as! Header).key_name!)
        }
        let (data, response) = try await URLSession.shared.data(from: URL(string: endpoint.url!)!)
        guard let httpResponse = response as? HTTPURLResponse else { return false}
        if !(endpoint.expectedResponse ?? "").isEmpty {
                if String(data:data, encoding: .utf8)! != endpoint.expectedResponse! {
                    return false
                }
        }
        return httpResponse.statusCode == endpoint.expectedStatus
    } catch {
        print(error.localizedDescription)
        return false;
    }
}
