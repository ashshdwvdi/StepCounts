//
//  HomeViewModel.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

import HealthKit

class HomeViewModel: ViewModel {
    //TODO: - Decouple health store
    private static let healthStore = HKHealthStore()
    private lazy var viewHandler: HomeViewHandling? = nil
    private var stepCountRecords: StepCountRecords = []
    
    //TODO: - Inject in view model
    private static let currentDate = Date()
    private static let maxYearsInPast: Int = 20
    
    
    // MARK: - Public methods
    
    func viewDidLoad() {
        self.handleFetchStepCounts()
    }
    
    func setViewHandler(_ viewHandler: HomeViewHandling?) {
        self.viewHandler = viewHandler
    }
    
    
    // MARK: - Private methods
    
    private func handleFetchStepCounts() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes: Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            ]
            
            Self.healthStore.requestAuthorization(
                toShare: nil, read: readDataTypes) { [weak self](success, error) in
                if success {
                    self?.fetchStepCounts()
                }
            }
        }
    }
    
    private func fetchStepCounts() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        self.viewHandler?.showLoader()
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        let anchorDate = Calendar.current.startOfDay(for: Self.currentDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: dateComponents)
        
        query.initialResultsHandler = { [weak self] query, results, error in
            results?.enumerateStatistics(
                from: Self.defaultDistantPastDate(),
                to: Self.currentDate,
                with: { (result, stop) in
                    if let stepCountRecord = StepCountRecord(
                        stepCount: result.sumQuantity()?.doubleValue(for: HKUnit.count()),
                        dateTimeStamp: result.startDate) {
                        self?.populateStepCounts(stepCountRecord)
                    }
                })
            
            self?.viewHandler?.hideLoader()
        }
        
        Self.healthStore.execute(query)
    }
    
    private func populateStepCounts(_ record: StepCountRecord) {
        self.stepCountRecords.append(record)
    }
    
    /// Returns the max  past date else just returns current date
    private static func defaultDistantPastDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = -Self.maxYearsInPast
        return Calendar.current.date(
            byAdding: dateComponents, to: Self.currentDate) ?? Self.currentDate
    }
}
