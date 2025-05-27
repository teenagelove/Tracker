//
//  FilterType.swift
//  Tracker
//
//  Created by Danil Kazakov on 19.05.2025.
//

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all:
            return Constants.UIString.allTrackersFilter
        case .today:
            return Constants.UIString.todayTrackersFilter
        case .completed:
            return Constants.UIString.completedTrackersFilter
        case .uncompleted:
            return Constants.UIString.notCompletedTrackersFilter
        }
    }
    
    static var userDefaultsKey: String {
        return Constants.Keys.selectedFilterType
    }
}
