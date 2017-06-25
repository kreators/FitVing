
import Foundation
import HealthKit

class HealthManager {

    let storage = (UIApplication.shared.delegate as! AppDelegate).healthKitStore

    var isEnabled = false
    
    init() {
        _ = checkAuthorization()
    }
    
    func checkAuthorization() -> Bool {
        if isEnabled == true { return true }
        
        if HKHealthStore.isHealthDataAvailable() {
            let healthKitTypesToRead = Set<HKSampleType>(arrayLiteral:HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            storage.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
                self.isEnabled = success
                NotificationCenter.default.post(name: Notification.Name(rawValue: "HealthKitAuthorized"), object: nil)
            }
        }
        else {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func observeStepCount(_ handler:@escaping (_ steps: String) -> Void) {
        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let query = HKObserverQuery(sampleType: sampleType!, predicate: nil) {
            query, completionHandler, error in
            if error != nil {
                print("*** An error occured while setting up the stepCount observer. \(error!.localizedDescription) ***")
                abort()
            }
            self.stepsToday(handler)
             completionHandler()
        }
        storage.execute(query)
    }
    
    func stepsToday(_ handler:@escaping (_ steps: String) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date.Now())
        let startDateComponents = todayComponents
        let startDate = calendar.date(from: startDateComponents)

        var endDateComponents = todayComponents
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        let endDate = calendar.date(from: endDateComponents)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate!,
            intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            let statistics = results!.statistics() 
            if statistics.count == 0 {
                handler("0")
            } else {
                for statistic in statistics {
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        handler(String(value))
                    }
                }
            }
        }
        storage.execute(query)
    }

    func stepsAtDate(_ date: Date, handler:@escaping (_ steps: Double) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        let startDateComponents = todayComponents
        let startDate = calendar.date(from: startDateComponents)
        
        var endDateComponents = todayComponents
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        let endDate = calendar.date(from: endDateComponents)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate!, intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }

            if let results = results {
                let statistics = results.statistics()
                if statistics.count == 0 {
                    handler(0.0)
                } else {
                    for statistic in statistics {
                        if let quantity = statistic.sumQuantity() {
                            let date = statistic.startDate
                            let value = quantity.doubleValue(for: HKUnit.count())
                            handler(value)
                        }
                    }
                }
            }
        }
        storage.execute(query)
    }

    func stepsTodayHourInterval(_ completion:@escaping (_ steps: [CGFloat]?) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.hour = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date.Now())
                var stepsHourInterval = [CGFloat] (repeating: 0.0, count: 24)
        
        let startDateComponents = todayComponents
        let startDate = calendar.date(from: startDateComponents)
        
        var endDateComponents = todayComponents
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        let endDate = calendar.date(from: endDateComponents)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate!,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            if let results = results {
                let statistics = results.statistics()
                if statistics.count == 0 {
                    completion(stepsHourInterval)
                } else {
                    for statistic in statistics {
                        if let quantity = statistic.sumQuantity() {
                            let date = statistic.startDate
                            let value = CGFloat(quantity.doubleValue(for: HKUnit.count()))
                            let components = (calendar as NSCalendar).components([.year, .month, .day, .hour], from: date)
                            stepsHourInterval[components.hour!] += value
                        }
                    }
                    completion(stepsHourInterval)
                }
            }
        }
        storage.execute(query)
    }
    
    func stepsAtMonth(_ month: Int, year: Int, completion: @escaping ([Double], NSError?) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let now = Date.Now()
        var components = (calendar as NSCalendar).components([.year, .month, .day], from: now)
        if month != 0 {
            components.year = year
            components.month = month
        }
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date.Now())
        
        let range = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: now)
        let numberOfDaysInMonth = range.length
        
        var stepsInMonth = [Double] (repeating: 0.0, count: numberOfDaysInMonth)
        
        var startDateComponents = components
        startDateComponents.day = 1
        let startDate = calendar.date(from: startDateComponents)
        
        var endDateComponents = components
        endDateComponents.day = numberOfDaysInMonth
        endDateComponents.hour = 23
        endDateComponents.minute = 59
        endDateComponents.second = 59
        let endDate = calendar.date(from: endDateComponents)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate!,
            intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            if let results = results {
                let statistics = results.statistics()
                
                for statistic in statistics {
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        let components = (calendar as NSCalendar).components([.year, .month, .day], from: date)
                        stepsInMonth[components.day! - 1] += value
                    }
                }
                
                if components.year == todayComponents.year && components.month == todayComponents.month {
                    for index in todayComponents.day! ..< numberOfDaysInMonth {
                        stepsInMonth.removeLast()
                    }
                }
                completion(stepsInMonth, nil)
            }
        }
        storage.execute(query)
    }
    
    func stepsAtThisWeek(_ completion: @escaping ([Double], NSError?) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let now = Date.Now()

        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day, .weekday], from: now)
  
        var numberOfDaysInThisWeek = 0
        var startDateComponents = todayComponents
        if let weekday = startDateComponents.weekday {
            switch weekday {
            case 1:
                startDateComponents.day! -= 6
                numberOfDaysInThisWeek = 7
            case 2:
                startDateComponents.day! -= 0
                numberOfDaysInThisWeek = 1
            case 3:
                startDateComponents.day! -= 1
                numberOfDaysInThisWeek = 2
            case 4:
                startDateComponents.day! -= 2
                numberOfDaysInThisWeek = 3
            case 5:
                startDateComponents.day! -= 3
                numberOfDaysInThisWeek = 4
            case 6:
                startDateComponents.day! -= 4
                numberOfDaysInThisWeek = 5
            default:
                startDateComponents.day! -= 5
                numberOfDaysInThisWeek = 6
            }
        }
        let startDate = calendar.date(from: startDateComponents)
        var stepsInMonth = [Double] (repeating: 0.0, count: 7)
        let endDate = now
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate!,
            intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                abort()
            }
            
            if let results = results {
                let statistics = results.statistics()
                
                for statistic in statistics {
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        let components = (calendar as NSCalendar).components([.year, .month, .day], from: date)
                        stepsInMonth[components.day! - startDateComponents.day!] += value
                    }
                }
                completion(stepsInMonth, nil)
            }
        }
        storage.execute(query)
    }

    func stepsLast7Days(_ completion: @escaping ([Double], NSError?) -> Void) {
        guard isEnabled else { return }
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let now = Date.Now()
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: now)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date.Now())
        
        var startDateComponents = components
        startDateComponents.day! -= 7
        let startDate = calendar.date(from: startDateComponents)
        
        var stepsInMonth = [Double] (repeating: 0.0, count: 7)
        
        let endDate = now
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate!,
            intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                return;
            }
            
            if let results = results {
                let statistics = results.statistics() as [HKStatistics]
                
                for statistic in statistics {
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        let days = self.daysBetweenDate(date, endDate: endDate)
                        if days <= 6 {
                            stepsInMonth[6 - days] += value
                        }
                    }
                }
                completion(stepsInMonth, nil)
            }
        }
        storage.execute(query)
    }

    func stepsLast30Days(_ completion: @escaping ([CGFloat], NSError?) -> Void) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let now = Date.Now()
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: now)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date.Now())
        
        var startDateComponents = components
        startDateComponents.day! -= 29
        let startDate = calendar.date(from: startDateComponents)
        
        var stepsInMonth = [CGFloat] (repeating: 0.0, count: 30)
        
        let endDate = now
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate!,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                print("*** An error occurred while calculating the statistics: \(error!.localizedDescription) ***")
                return;
            }
            
            if let results = results {
                let statistics = results.statistics() as [HKStatistics]
                
                for statistic in statistics {
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = CGFloat(quantity.doubleValue(for: HKUnit.count()))
                        let days = self.daysBetweenDate(date, endDate: endDate)
                        if days <= 29 {
                            stepsInMonth[29 - days] += value
                        }
                    }
                }
                completion(stepsInMonth, nil)
            }
        }
        storage.execute(query)
    }

    
    func daysBetweenDate(_ startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
        
        return components.day!
    }
}

