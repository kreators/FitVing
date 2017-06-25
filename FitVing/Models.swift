
import Foundation
import RealmSwift

class ManualDeposit: Object {
    dynamic var amount: Double = 0.0
    dynamic var dateApplied: Date?
    dynamic var dateCreated: Date?
}

class TargetDeposit: Object {
    dynamic var amount: Double = 0.0
    dynamic var dateApplied: Date?
    dynamic var dateCreated: Date?
}

class TargetSteps: Object {
    dynamic var steps = 0
    dynamic var dateApplied: Date?
    dynamic var dateCreated: Date?
}

class DailyBalance: Object {
    dynamic var principal: Double = 0.0
    dynamic var balance: Double = 0.0
    dynamic var interest: Double = 0.0
    dynamic var targetDeposit: Double = 0.0
    dynamic var targetSteps = 0
    dynamic var steps = 0
    dynamic var dateApplied: Date?
    dynamic var dateCreated: Date?
}

class TortoiseConfiguration: Object {
    dynamic var dateInstalled: Date?
    dynamic var dateCreated: Date?
    dynamic var dateUpdated: Date?
}
