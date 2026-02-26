//
//  LessonPlaybackType.swift
//  combatflows
//
//  Created by Michael on 2026-02-25.
//  Copyright © 2026 ilearningsolutions. All rights reserved.
//


import Foundation

// MARK: - Lesson Types (Replaces CMABaseContent.h Enums)
enum LessonPlaybackType: String, Codable {
    case teaching = "teaching"
    case application = "application"
    case graphicGuide = "graphicguide"
}

// MARK: - Lesson (Replaces CMALesson.m)
struct Lesson: Identifiable, Hashable {
    let id = UUID()
    let filename: String
    let type: LessonPlaybackType
}

// MARK: - Flow (Replaces CMAFlow.m)
/// Note: This isn't directly Decodable because it is constructed 
/// dynamically from the string arrays in FlowGroup.
struct Flow: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let ordinal: Int
    let nominal: Int
    let lessons: [Lesson]
    let bannerPaths: [String]
    let cardPaths: [String]
    let thumbnailName: String // MUST BE ADDED
    
    // Explicit hashing to satisfy Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Flow, rhs: Flow) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Flow Group (Replaces CMAFlowGroup.m)
struct FlowGroup: Codable, Identifiable, Hashable {
    // Satisfies Identifiable using the unique product string
    var id: String { productIdentifier } 
    
    let productIdentifier: String
    let name: String
    let text: String?
    let detail: String?
    let bundled: Bool
    
    // Legacy JSON keys mapped cleanly to camelCase
    let listImage: String?
    let thumbs: [String]?
    let graphicGuideBanners: [String]?
    let graphicGuideCards: [String]?
    let enabledValue: Int? 
    
    // The raw array of string arrays from JSON
    let rawFlows: [[String]]?

    // Map the weird JSON keys to our clean Swift properties
    enum CodingKeys: String, CodingKey {
        case productIdentifier, name, text, detail, bundled, thumbs
        case graphicGuideBanners, graphicGuideCards
        case listImage = "tableimage"
        case enabledValue = "enabled"
        case rawFlows = "flows"
    }
    
    var isEnabled: Bool {
        return enabledValue == 1
    }
    
    // MARK: - The Parsing Logic (Translated from CMAFlow.m)
    var combatFlows: [Flow] {
        guard let rawFlows = rawFlows else { return [] }
        
        return rawFlows.compactMap { lessonFilenames in
            // Parse: "01-combatflow-1-application.m4v" -> ordinal: 1, nominal: 1
            guard let firstFilename = lessonFilenames.first else { return nil }
            let components = firstFilename.components(separatedBy: "-")
            guard components.count >= 3 else { return nil }
            
            let ordinal = Int(components[0]) ?? 0
            let nominal = Int(components[2]) ?? 0
            
            // 1. Parse Lessons
            let parsedLessons: [Lesson] = lessonFilenames.compactMap { filename in
                let fileComponents = filename.components(separatedBy: "-")
                guard fileComponents.count >= 4 else { return nil }
                
                let typeString = fileComponents[3].replacingOccurrences(of: ".m4v", with: String())
                
                let type: LessonPlaybackType
                if typeString.contains("application") { type = .application }
                else if typeString.contains("teaching") { type = .teaching }
                else if typeString.contains("graphicguide") { type = .graphicGuide }
                else { return nil }
                
                return Lesson(filename: filename, type: type)
            }
            
            // 2. Filter Banners and Cards by matching nominal
            let banners = graphicGuideBanners?.filter { path in
                let pathComps = path.components(separatedBy: "-")
                if pathComps.count >= 3, let pathNominal = Int(pathComps[2]) {
                    return pathNominal == nominal
                }
                return false
            } ?? []
            
            let cards = graphicGuideCards?.filter { path in
                let pathComps = path.components(separatedBy: "-")
                if pathComps.count >= 3, let pathNominal = Int(pathComps[2]) {
                    return pathNominal == nominal
                }
                return false
            } ?? []
            
            return Flow(
                name: self.name,
                ordinal: ordinal,
                nominal: nominal,
                lessons: parsedLessons,
                bannerPaths: banners,
                cardPaths: cards,
                thumbnailName: self.listImage ?? ""
            )
        }
    }
}
