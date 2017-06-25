
import Foundation
import RealmSwift

extension FitVing {
    
    func todayDeposit() -> Double {
        var todayDeposit = 0.0

        let realm = try! Realm()
        let manualDeposits = realm.objects(ManualDeposit.self)
        let today = Date.Now()
        for manualDeposit in manualDeposits {
            if let dateApplied = manualDeposit.dateApplied {
                if isSameday(dateApplied, from: today) {
                    if manualDeposit.amount > 0.0 {
                        todayDeposit += manualDeposit.amount
                    }
                }
            }
        }

        if todayBalance.targetSteps > 0 {
            todayDeposit += todayBalance.targetDeposit * Double(todayBalance.steps) / Double(todayBalance.targetSteps)
        }
        return todayDeposit
    }
    
    func totalDeposit() -> Double {
        var totalDeposit = 0.0
        let realm = try! Realm()
        let manualDeposits = realm.objects(ManualDeposit.self)
        for manualDeposit in manualDeposits {
            if let dateApplied = manualDeposit.dateApplied {
                if dateApplied < Date.Now() {
                    if manualDeposit.amount > 0.0 {
                        totalDeposit += manualDeposit.amount
                    }
                }
            }
        }

        let dailyBalances = realm.objects(DailyBalance.self)
        for dailyBalance in dailyBalances {
            if let dateApplied = dailyBalance.dateApplied {
                if dateApplied < Date.Now() {
                    if dailyBalance.targetSteps > 0 {
                        totalDeposit += dailyBalance.targetDeposit * Double(dailyBalance.steps) / Double(dailyBalance.targetSteps)
                    }
                }
            }
        }
        return totalDeposit
    }

    func totalWithdraw() -> Double {
        var totalWithdraw = 0.0
        let realm = try! Realm()
        let manualDeposits = realm.objects(ManualDeposit.self)
        for manualDeposit in manualDeposits {
            if let dateApplied = manualDeposit.dateApplied {
                if dateApplied < Date.Now() {
                    if manualDeposit.amount < 0.0 {
                        totalWithdraw += manualDeposit.amount
                    }
                }
            }
        }
        return totalWithdraw
    }
}
