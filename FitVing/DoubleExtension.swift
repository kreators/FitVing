
import Foundation

extension Double {
    func printPrecision() -> Double {
        return floor(self * 10) / 10
    }
}
