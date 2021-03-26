//
//  HomeViewModel.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

import HealthKit

class HomeViewModel: ViewModel {
    private static let healthStore = HKHealthStore()
    private var viewHandler: HomeViewHandling? = nil
    
    
    // MARK: - Public methods
    
    func setViewHandler(_ viewHandler: HomeViewHandling?) {
        self.viewHandler = viewHandler
    }
    
    func handleFetchStepCounts() {
        if HKHealthStore.isHealthDataAvailable() {
            let readDataTypes: Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            ]
            
            let writeDataTypes: Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            ]
            
            Self.healthStore.requestAuthorization(
                toShare: writeDataTypes, read: readDataTypes) { [weak self](success, error) in
                if success {
                    self?.fetchStepCounts()
                }
            }
        }
    }
    
    
    // MARK: - Private methods
    
    private func fetchStepCounts() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        self.viewHandler?.showLoader()
        var dateComponents = DateComponents()
        dateComponents.hour = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate!,
            intervalComponents: dateComponents)
        
        query.initialResultsHandler = { query, results, error in
            self.viewHandler?.hideLoader()
            
            let startDate = calendar.startOfDay(for: Date())
            results?.enumerateStatistics(
                from: startDate,
                to: Date(),
                with: { (result, stop) in
                    print("Time: \(result.startDate), \(result.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)")
                })
        }
        
        Self.healthStore.execute(query)
    }
}
