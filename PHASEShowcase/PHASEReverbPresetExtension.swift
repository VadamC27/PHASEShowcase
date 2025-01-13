//
//  PHASEReverbPresetExtension.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 13/01/2025.
//
import PHASE

extension PHASEReverbPreset: @retroactive CaseIterable {
    public static var allCases: [PHASEReverbPreset] {
        return [.none, .smallRoom, .mediumRoom, .largeRoom, .largeRoom2, .mediumHall, .mediumHall2, .mediumHall3,.largeHall,.largeHall2 , .mediumChamber, .largeChamber, .cathedral]
    }
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .smallRoom: return "Small Room"
        case .mediumRoom: return "Medium Room"
        case .largeRoom: return "Large Room"
        case .mediumHall: return "Medium Hall"
        case .mediumHall2: return "Medium Hall 2"
        case .mediumHall3: return "Medium Hall 3"
        case .largeHall: return "Large Hall"
        case .largeRoom2: return "Large Room 2"
        case .largeHall2: return "Large Hall 2"

        case .mediumChamber: return "Medium Chamber"
        case .largeChamber: return "Large Chamber"
        case .cathedral: return "Cathedral"
        @unknown default: return "Unknown"
        }
    }
}

