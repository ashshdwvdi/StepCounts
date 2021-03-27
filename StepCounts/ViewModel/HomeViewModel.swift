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
    
    private var inputStepCount: Double = 0
    private(set) var resultString: String = ""
    
    // Throttle user input step count before checking steps
    private var dateForStepsReachedFetchCount = 0
    
    private enum StepRecordResult {
        case noRecordsData
        case stepCountLessThanZero
        case success( _ date: Date)
        case none
        
        var result: String {
            switch self {
                case .noRecordsData:
                    return "Steps Records data not found!, unable to check 🧐"
                case .stepCountLessThanZero:
                    return "Hey! enter steps more than 0 🥸"
                case .success(let goalAchivedOnDate):
                    return "Congo! 🥳 you achieved your goal on: \(goalAchivedOnDate)"
                case .none:
                    return "Hey! enter some steps 🥸"
            }
        }
    }
    
    
    // MARK: - Public methods
    
    func viewDidLoad() {
        self.handleFetchStepCounts()
    }
    
    func setViewHandler(_ viewHandler: HomeViewHandling?) {
        self.viewHandler = viewHandler
    }
    
    func setInputStepCount(_ input: String?) {
        guard let input = input, let value = Double(input) else {
            self.resultString = StepRecordResult.none.result
            self.viewHandler?.reloadView()
            return
        }
        
        guard value > 0 else {
            self.resultString = StepRecordResult.stepCountLessThanZero.result
            self.viewHandler?.reloadView()
            return
        }
        
        guard self.stepCountRecords.isEmpty == false else {
            self.resultString = StepRecordResult.noRecordsData.result
            self.viewHandler?.reloadView()
            return
        }
        
        self.inputStepCount = value
        
        self.dateForStepsReachedFetchCount += 1
        self.handleDateCheckForStepsReached(
            stepCount: value, fetchId: self.dateForStepsReachedFetchCount)
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
    
    private func handleDateCheckForStepsReached(
        stepCount: Double,
        fetchId: Int
    ) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(500)) {[weak self] in
            guard fetchId == self?.dateForStepsReachedFetchCount else { return }
            
            if let goalDate = self?.getDateForStepsReached(stepCount) {
                self?.resultString = StepRecordResult.success(goalDate).result
                self?.viewHandler?.reloadView()
            }
        }
    }
    
    private func getDateForStepsReached(_ stepCount: Double) -> Date? {
        return nil
    }
}
