//
//  StepCountRecord.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 27/03/21.
//

import Foundation

typealias StepCountRecords = [StepCountRecord]

struct StepCountRecord {
    let stepCount: Double
    let dateTimeStamp: Date
    
    init?(stepCount: Double?, dateTimeStamp: Date) {
        guard let steps = stepCount, steps > 0 else { return nil }
        self.stepCount = steps
        self.dateTimeStamp = dateTimeStamp
    }
}
