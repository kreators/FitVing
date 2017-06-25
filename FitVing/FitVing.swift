
import Foundation
import Flurry_iOS_SDK
import RealmSwift
import Alamofire

final class FitVing {
    static let sharedInstance = FitVing()
    fileprivate init() {}
    
    var homeViewController: HomeViewController? = nil
    var valuesInitialized = false
    let serialSemaphore = DispatchSemaphore(value: 1)
    
    let healthManager = HealthManager()
    
    var currentLocality: String? = nil
    
    var facebookUserId: String? = nil
    var facebookUsername: String? = nil
    var stepsObjectId: String? = nil
    
    let todayBalance = DailyBalance()
    
    var currentBalance: Double {
        if let dateApplied = todayBalance.dateApplied {
            if isSameday(dateApplied, from: Date.Now()) {
                return todayBalance.balance
            }
        }
        return readYesterdayBalance() ?? 0.0
    }

    var currentPrincipal: Double {
        if let dateApplied = todayBalance.dateApplied {
            if isSameday(dateApplied, from: Date.Now()) {
                return todayBalance.principal
            }
        }
        return readYesterdayBalance() ?? 0.0
    }
    
    var currentInterestRate: Double {
        if let dateApplied = todayBalance.dateApplied {
            if isSameday(dateApplied, from: Date.Now()) {
                return todayBalance.interest
            }
        }
        return 0.0
    }

    
    var currencySymbol: String {
        guard let symbol = NSLocale.current.currencySymbol else { return "$" }
        if symbol.characters.count != 1 {
            return "$"
        }
        return symbol
    }

    var tortoiseUserId: String? {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "tortoiseUserId")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let tortoiseUserId = userDefault.object(forKey: "tortoiseUserId") {
                return tortoiseUserId as? String
            }
            return nil
        }
    }

    var tortoiseUserEmail: String? {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "tortoiseUserEmail")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let tortoiseUserEmail = userDefault.object(forKey: "tortoiseUserEmail") {
                return tortoiseUserEmail as? String
            }
            return nil
        }
    }

    var SPUserId: String? {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "SPUserId")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let SPUserId = userDefault.object(forKey: "SPUserId") {
                return SPUserId as? String
            }
            return nil
        }
    }

    var SPBankId: String? {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "SPBankId")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let SPBankId = userDefault.object(forKey: "SPBankId") {
                return SPBankId as? String
            }
            return nil
        }
    }

    var userId: String? {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "facebookUserId")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let userId = userDefault.object(forKey: "facebookUserId") {
                return userId as? String
            }
            return nil
        }
    }

    var targetStep: Int {
        set {
            let userDefault = UserDefaults.standard
            userDefault.set(newValue, forKey: "targetStep")
            userDefault.synchronize()
        }
        get {
            let userDefault = UserDefaults.standard
            if let targetStep = userDefault.object(forKey: "targetStep") as? Int {
                return targetStep
            }
            return 0
        }
    }
    
    var depositAmount: Double {
        set {
            addDeposit(newValue)
        }
        get {
            return readLastDeposit()
        }
    }

    // MARK: - Helpers
    
    func lastdailybalanceAtCloud() {
        return;
        guard let id = self.tortoiseUserId else { return }
        let params = ["id":id]
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/lastdailybalance", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                        }
                    } else {
                    }
                }
        }
    }

    func lastdailybalancesAtCloud() {
        guard let id = self.tortoiseUserId else { return }
        let now = Date.Now()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let searchDate = dateFormatter.string(from: now)

        self.serialSemaphore.wait()
        let params = ["id":id, "dateApplied":searchDate]
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/lastdailybalances", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let dailyBalances = JSON["data"] as? [[String:String]] {
                                self.updateDailyBalanceWithCloud(dailyBalances: dailyBalances)
                            }
                        }
                    } else {
                    }
                } else {
                    FitVing.sharedInstance.serialSemaphore.signal()
                }
        }
    }
    
    fileprivate func updateDailyBalanceWithCloud(dailyBalances: [[String:String]]) {
        let realm = try! Realm()
        for dailyBalance in dailyBalances {
            if let searchDateString = dailyBalance["dateApplied"] {
                let filterDate = searchDate(date: searchDateString)
                let startDate = filterDate.0
                let endDate = filterDate.1
                let balances = realm.objects(DailyBalance.self).filter("dateApplied BETWEEN %@", [startDate, endDate])
                try! realm.write {
                    realm.delete(balances)
                }
                    if let principal = dailyBalance["principal"], let balance = dailyBalance["balance"], let interest = dailyBalance["interest"], let targetDeposit = dailyBalance["targetDeposit"], let targetSteps = dailyBalance["targetSteps"], let steps = dailyBalance["steps"], let dateApplied = dailyBalance["dateApplied"] {
                        let balanceRecord = DailyBalance()
                        balanceRecord.principal = Double(principal)!
                        balanceRecord.balance = Double(balance)!
                        balanceRecord.interest = Double(interest)!
                        balanceRecord.steps = Int(steps)!
                        balanceRecord.targetSteps = Int(targetSteps)!
                        balanceRecord.targetDeposit = Double(targetDeposit)!
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        formatter.timeZone = TimeZone(identifier: "GMT")
                        balanceRecord.dateApplied = formatter.date(from: dateApplied)!
                        balanceRecord.dateCreated = Date.Now()
                        try! realm.write {
                            realm.add(balanceRecord)
                        }
                    }
            }
        }
        FitVing.sharedInstance.serialSemaphore.signal()
    }
    
    fileprivate func searchDate(date: String) -> (Date, Date) {
        let dateString = date.components(separatedBy: " ")
        let startDateString = dateString[0] + " 00:00:00"
        let endDateString = dateString[0] + " 23:59:59"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "GMT")
        guard let startDate = formatter.date(from: startDateString) else { return (Date.Now(), Date.Now()) }
        guard let endDate = formatter.date(from: endDateString) else { return (Date.Now(), Date.Now()) }
        return (startDate, endDate)
    }

    // MARK: - DB Init
    
    func signupCompleted() {
        initConfiguration()
        initDailyBalance()
    }
    
    func eraseTortoiseData() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    fileprivate func initConfiguration() {
        let realm = try! Realm()
        let configuration = TortoiseConfiguration()
        let now = Date.Now()
        configuration.dateCreated = now
        configuration.dateInstalled = now
        configuration.dateUpdated = now
        try! realm.write {
            realm.add(configuration)
        }
    }
    
    fileprivate func initDailyBalance() {
        let realm = try! Realm()
        let yesterday = Date(timeInterval: -86400, since: Date.Now())
        let balance = DailyBalance()
        balance.principal = 0.0
        balance.balance = 0.0
        balance.interest = 0.0
        balance.steps = 0
        balance.targetSteps = 0
        balance.targetDeposit = 0.0
        balance.dateApplied = yesterday
        balance.dateCreated = Date.Now()
        try! realm.write {
            realm.add(balance)
        }
    }


    func readLastDeposit() -> Double {
        let realm = try! Realm()
        let deposits = realm.objects(TargetDeposit.self).sorted(byKeyPath: "dateCreated", ascending: false)
        guard deposits.count > 0 else { return 0.0 }
        guard let lastDeposit = deposits.first else { return 0.0 }
        return lastDeposit.amount
    }
    
    func addDeposit(_ amount: Double) {
        let realm = try! Realm()
        let deposit = TargetDeposit()
        deposit.amount = amount
        deposit.dateCreated = Date()
        try! realm.write {
            realm.add(deposit)
        }
    }
    
    func readManualDeposits(_ date: Date) -> [ManualDeposit]? {
        return nil
    }

    func readLastManualDeposit() -> Double {
        let realm = try! Realm()

        let deposits = realm.objects(ManualDeposit.self).sorted(byKeyPath: "dateCreated", ascending: false)
        guard deposits.count > 0 else { return 0.0 }
        guard let lastDeposit = deposits.first else { return 0.0 }
        return lastDeposit.amount

    }

    func readLastBalance() -> Double? {
        return nil
    }

    func last100DailyBalances() -> [[String:String]] {
        var dailyBalances = [[String:String]]()
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return dailyBalances }
        let count = balances.count >= 100 ? 99 : balances.count
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        for i in 0 ..< count {
            let balance = balances[i]
            var dict = [String:String]()
            dict["principal"] = String(balance.principal)
            dict["balance"] = String(balance.balance)
            dict["interest"] = String(balance.interest)
            dict["targetDeposit"] = String(balance.targetDeposit)
            dict["targetSteps"] = String(balance.targetSteps)
            dict["steps"] = String(balance.steps)
            if let dateApplied = balance.dateApplied {
                dict["dateApplied"] = dateFormatter.string(from: dateApplied)
            }
            if let dateCreated = balance.dateCreated {
                dict["dateCreated"] = dateFormatter.string(from: dateCreated)
            }
            dailyBalances.append(dict)
        }
        print("\(#function) : \(dailyBalances)")
        return dailyBalances
    }

    func last30DayBalances() -> [CGFloat] {
        var last30Balances = [CGFloat](repeating: 0.0, count: 30)
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return last30Balances }
        last30Balances[0] = CGFloat(self.currentBalance)
        let count = balances.count > 29 ? 29 : balances.count
        for i in 0 ..< count {
            let balance = balances[i]
            last30Balances[i + 1] = CGFloat(balance.balance)
        }
        last30Balances = last30Balances.reversed()
        return last30Balances
    }

    func last30DayInitialBalance() -> Double {
        var principal = 0.0
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return 0.0 }
        let count = balances.count > 29 ? 29 : balances.count
        for i in 0 ..< count {
            let balance = balances[i]
            principal = balance.principal
        }
        return principal
    }
    
    func last30DayInterestRateAPY() -> Double {
        var rateAPY = 0.0
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return 0.0 }
        let count = balances.count > 29 ? 29 : balances.count
        var numberOfRate = 0
        for i in 0 ..< count {
            let balance = balances[i]
            let interest = balance.interest
            if interest > 0.0 {
                rateAPY += interestRateAPY(interestRate: balance.interest)
                numberOfRate += 1
            }
        }
        let todayRate = currentInterestRate
        rateAPY += interestRateAPY(interestRate: todayRate)
        if todayRate > 0.0 {
            numberOfRate += 1
        }
        guard numberOfRate > 0 else { return 0.0 }
        let averageRate = rateAPY / Double(numberOfRate)
        let returnValue = floor(averageRate * 100000) / 100000

        return returnValue
    }

    fileprivate func dailyBalance(at: Date) -> Double {
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return 0.0 }
        for balance in balances {
            if let dateApplied = balance.dateApplied {
                if isSameday(at, from: dateApplied) {
                    return balance.balance
                }
            }
        }
        return 0.0
    }


    func lastDailyBalanceDate() -> Date? {
        let realm = try! Realm()

        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false).filter("dateApplied < %@", Date.Now())
        guard balances.count > 0 else { return nil }
        guard let last = balances.first else { return nil }
        guard let dateApplied = last.dateApplied else { return nil }
        return dateApplied
    }
    
    
    func createLastBalance(_ amount: Double, date: Date) {
        print("NEEDEDEDEDEED createLastBalance")

    }
    
    fileprivate func createDailyBalance(principal: Double, balance: Double, interest: Double, targetDeposit: Double, targetSteps: Int, steps: Int, dateApplied: Date, dateCreated: Date) {
        let realm = try! Realm()
        let dailyBalance = DailyBalance()
        dailyBalance.principal = principal
        dailyBalance.balance = balance
        dailyBalance.interest = interest
        dailyBalance.steps = steps
        dailyBalance.targetSteps = targetSteps
        dailyBalance.targetDeposit = targetDeposit
        dailyBalance.dateApplied = dateApplied
        dailyBalance.dateCreated = dateCreated
        try! realm.write {
            realm.add(dailyBalance)
        }
    }
    
    func targetDeposit(at: Date) -> Double {
        let realm = try! Realm()
        let targetDeposits = realm.objects(TargetDeposit.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard targetDeposits.count > 0 else { return 0.0 }
        for targetDeposit in targetDeposits {
            if let dateApplied = targetDeposit.dateApplied {
                if dateApplied.compare(at) == .orderedAscending {
                    return targetDeposit.amount
                }
                if isSameday(dateApplied, from: at) {
                    return targetDeposit.amount
                }
            }
        }
        return 0.0
    }

    func manualDeposit(at: Date) -> Double {
        let realm = try! Realm()
        let manualDeposits = realm.objects(ManualDeposit.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard manualDeposits.count > 0 else { return 0.0 }
        var manualDepositAmount = 0.0
        for manualDeposit in manualDeposits {
            if let dateApplied = manualDeposit.dateApplied {
                if isSameday(dateApplied, from: at) {
                    manualDepositAmount += manualDeposit.amount
                }
            }
        }
        return manualDepositAmount
    }

    func targetSteps(at: Date) -> Int {
        let realm = try! Realm()
        let targetSteps = realm.objects(TargetSteps.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard targetSteps.count > 0 else { return 0 }
        for targetStep in targetSteps {
            if let dateApplied = targetStep.dateApplied {
                if dateApplied.compare(at) == .orderedAscending {
                    return targetStep.steps
                }
                if isSameday(dateApplied, from: at) {
                    return targetStep.steps
                }
            }
        }
        return 0
    }

    func addManualDeposit(_ amount: Double, date: Date) {
        let realm = try! Realm()
        let deposit = ManualDeposit()
        deposit.amount = amount
        deposit.dateApplied = date
        deposit.dateCreated = Date.Now()
        try! realm.write {
            realm.add(deposit)
        }
    }

    func addTargetDeposit(_ amount: Double, date: Date) {
        let realm = try! Realm()
        let deposit = TargetDeposit()
        deposit.amount = amount
        deposit.dateApplied = date
        deposit.dateCreated = Date.Now()
        try! realm.write {
            realm.add(deposit)
        }
    }

    func addTargetSteps(_ steps: Int, date: Date) {
        let realm = try! Realm()
        let targetSteps = TargetSteps()
        targetSteps.steps = steps
        targetSteps.dateApplied = date
        targetSteps.dateCreated = Date.Now()
        try! realm.write {
            realm.add(targetSteps)
        }
    }

    func processDailyBalances() {
        let semaphore = DispatchSemaphore(value: 1)
        if let lastDate = lastDailyBalanceDate() {
            var nextDate = lastDate
            var prevDate = lastDate
            repeat {
                nextDate = prevDate.addingTimeInterval(86400)
                guard nextDate.compare(Date.Now()) == .orderedAscending else { return }
                semaphore.wait()
                self.healthManager.stepsAtDate(nextDate, handler: { (steps) in
                    let balance = self.dailyBalance(at: prevDate)
                    let targetDeposit = self.targetDeposit(at: nextDate)
                    let manualDeposit = self.manualDeposit(at: nextDate)
                    let targetSteps = self.targetSteps(at: nextDate)
                    let amount = self.calculateCashAmount(targetDeposit, manualDepositAmount: manualDeposit, lastBalance: balance, targetSteps: targetSteps, steps: steps)
                    let interest = self.interestRate(targetSteps: targetSteps, steps: steps)
                    self.createDailyBalance(principal: balance, balance: amount, interest: interest, targetDeposit: targetDeposit, targetSteps: targetSteps, steps: Int(steps), dateApplied: nextDate, dateCreated: Date.Now())
                    prevDate = prevDate.addingTimeInterval(86400)
                    semaphore.signal()
                })
            } while isYesterday(nextDate, from: Date.Now()) == false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ProcessDailyBalancesCompleted"), object: nil)
        }
    }
    
    func readYesterdayBalance() -> Double? {
        let realm = try! Realm()
        let balances = realm.objects(DailyBalance.self).sorted(byKeyPath: "dateApplied", ascending: false)
        guard balances.count > 0 else { return nil }
        for balance in balances {
            guard let dateApplied = balance.dateApplied else { return nil }
            if dateApplied > Date.Now() {
                try! realm.write {
                    realm.delete(balance)
                }
            } else {
                if isYesterday(dateApplied, from: Date.Now()) {
                    return balance.balance
                }
            }
        }
        return nil
    }
    
    func checkDailyBalances() {
        if let lastBalance = readYesterdayBalance() {
            print("lastBalance : \(lastBalance)")
        } else {
            print("NO BALANCE YESTERDAY")
            processDailyBalances()
        }
    }
    
    func daysBetweenDate(_ startDate: Date, endDate: Date) -> Int
    {
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components([.day], from: startDate, to: endDate, options: [])
        
        return components.day!
    }
    
    func isYesterday(_ date: Date, from: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let yesterdayComponent = (calendar as NSCalendar).components([.year, .month, .day], from: from.addingTimeInterval(-86400))
        let dateComponent = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        if yesterdayComponent.year == dateComponent.year && yesterdayComponent.month == dateComponent.month && yesterdayComponent.day == dateComponent.day {
            return true
        }
        return false
    }
    
    func isSameday(_ date: Date, from: Date) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let compareDayComponent = (calendar as NSCalendar).components([.year, .month, .day], from: from)
        let dayComponent = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        if compareDayComponent.year == dayComponent.year && compareDayComponent.month == dayComponent.month && compareDayComponent.day == dayComponent.day {
            return true
        }
        return false
    }


    func flurryLogEvent(_ event: String) {
        if let facebookId = FitVing.sharedInstance.facebookUserId, let facebookUsername = FitVing.sharedInstance.facebookUsername {
            let params = ["facebookId":facebookId, "facebookUsername":facebookUsername]
            Flurry.logEvent(event, withParameters: params)
        }
    }
    
    func calculateCashAmount(_ targetDeposit: Double, manualDepositAmount: Double, lastBalance: Double, targetSteps: Int, steps: Double, skipUpdate: Bool = false) -> Double {
        let valueOfSteps = targetSteps > 0 ? targetDeposit / Double(targetSteps) : 0.0
        var cashAmount = lastBalance + manualDepositAmount
        var stepsCounted = Int(steps)
        var rate = 1.0
        
        if stepsCounted >= targetSteps {
            stepsCounted = targetSteps
            rate = 1.0000411
            cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
        } else {
            if stepsCounted >= 10000 {
                rate = 1.0000411
            }
            else if stepsCounted >= 9000 {
                rate = 1.00003216
            }
            else if stepsCounted >= 8000 {
                rate = 1.00002469
            }
            else if stepsCounted >= 7000 {
                rate = 1.00001753
            }
            else if stepsCounted >= 6000 {
                rate = 1.00001096
            }
            else if stepsCounted >= 5000 {
                rate = 1.0000064
            }
            else if stepsCounted >= 4000 {
                rate = 1.00000342
            }
            else if stepsCounted >= 3000 {
                rate = 1.00000171
            }
            else if stepsCounted >= 2000 {
                rate = 1.00000034
            }
            else if stepsCounted >= 1000 {
                rate = 1.00000017
            }
            else if stepsCounted > 0 {
                rate = 1.00000003
            }
            cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            
        }
        
        var calculatedCashAmount = floor(cashAmount * 100000) / 100000
        
        if skipUpdate == false {
            todayBalance.dateApplied = Date.Now()
            todayBalance.dateCreated = Date.Now()
            todayBalance.interest = rate - 1.0
            todayBalance.balance = calculatedCashAmount
            todayBalance.principal = lastBalance
            todayBalance.steps = stepsCounted
            todayBalance.targetSteps = targetSteps
            todayBalance.targetDeposit = targetDeposit
            print(todayBalance)
        }
        
        return calculatedCashAmount
    }

    func calculateInterestAmount(_ depositAmount: Double, manualDepositAmount: Double, lastBalance: Double, targetSteps: Int, steps: Double) -> Double {
        let valueOfSteps = depositAmount / Double(targetSteps)
        var cashAmount = lastBalance + manualDepositAmount
        var stepsCounted = Int(steps)
        
        if stepsCounted >= targetSteps {
            stepsCounted = targetSteps
            let rate = 0.0000411
            cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
        } else {
            if stepsCounted >= 10000 {
                let rate = 0.0000411
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 9000 {
                let rate = 0.00003216
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 8000 {
                let rate = 0.00002469
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 7000 {
                let rate = 0.00001753
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 6000 {
                let rate = 0.00001096
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 5000 {
                let rate = 0.0000064
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 4000 {
                let rate = 0.00000342
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 3000 {
                let rate = 0.00000171
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 2000 {
                let rate = 0.00000034
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted >= 1000 {
                let rate = 0.00000017
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
            else if stepsCounted > 0 {
                let rate = 0.00000003
                cashAmount = rate * (lastBalance + manualDepositAmount + valueOfSteps * Double(stepsCounted))
            }
        }
        
        let calculatedCashAmount = floor(cashAmount * 1000000000) / 1000000000
        
        return calculatedCashAmount
    }

    func interestRate(targetSteps: Int, steps: Double) -> Double {
        let stepsCounted = Int(steps)
        var interestRate = 0.0
        
        if stepsCounted >= targetSteps {
            interestRate = 0.0000411
        } else {
            if stepsCounted >= 10000 {
                interestRate = 0.0000411
            }
            else if stepsCounted >= 9000 {
                interestRate = 0.00003216
            }
            else if stepsCounted >= 8000 {
                interestRate = 0.00002469
            }
            else if stepsCounted >= 7000 {
                interestRate = 0.00001753
            }
            else if stepsCounted >= 6000 {
                interestRate = 0.00001096
            }
            else if stepsCounted >= 5000 {
                interestRate = 0.0000064
            }
            else if stepsCounted >= 4000 {
                interestRate = 0.00000342
            }
            else if stepsCounted >= 3000 {
                interestRate = 0.00000171
            }
            else if stepsCounted >= 2000 {
                interestRate = 0.00000034
            }
            else if stepsCounted >= 1000 {
                interestRate = 0.00000017
            }
            else if stepsCounted > 0 {
                interestRate = 0.00000003
            }
        }
        return interestRate
    }

    func interestRateAPY(interestRate: Double) -> Double {
        let rateAPY = interestRate * (365.0 * 100.0)
        let calculatedInterestRate = floor(rateAPY * 100000) / 100000
        return calculatedInterestRate
    }
}
