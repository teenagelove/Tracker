//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
}
