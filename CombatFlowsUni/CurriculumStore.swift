//
//  CurriculumStore.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//


import SwiftUI

@Observable
class CurriculumStore {
    var flowGroups: [FlowGroup] = []
    
    init() {
        loadFlows()
    }
    
    func loadFlows() {
        // Find the JSON file in the bundle
        guard let url = Bundle.main.url(forResource: "flows", withExtension: "json") else {
            print("Error: flows.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Decode the JSON directly into our Swift structs
            let decodedGroups = try decoder.decode([FlowGroup].self, from: data)
            
            // Filter enabled groups and store them
            self.flowGroups = decodedGroups.filter { $0.isEnabled }
            
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}
