//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.05.2025.
//

import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "3e6fd2d6-5e45-4266-bd8d-9938ae3e0f53") else {
            return
        }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [screen: screen]
        
        if let item = item {
            params["item"] = item
        }
        
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("Error reporting event: \(error.localizedDescription)")
        }
    }
}
