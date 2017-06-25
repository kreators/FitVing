
import Foundation

extension Date {
    static func Now() -> Date {
        /* DEBUG let returnDate = Date(timeIntervalSinceNow: 40500 - 7200 - 3840) */
        let returnDate = Date() //Date(timeIntervalSinceNow: -86400)
        return returnDate
    }
}
