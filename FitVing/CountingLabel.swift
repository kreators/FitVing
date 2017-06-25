
import UIKit

class CountingLabel: UILabel {
    
    fileprivate var startingValue: CGFloat = 0.0
    fileprivate var destinationValue: CGFloat = 0.0
    fileprivate var timer: Timer? = nil
    fileprivate var progress: TimeInterval = 0
    fileprivate var lastUpdate: TimeInterval = 0
    fileprivate var totalTime: TimeInterval = 0
    
    var format: String? = nil

    // MARK: - Helpers
    
    func count(_ startValue: CGFloat, endValue: CGFloat, duration: TimeInterval) {
        self.startingValue = startValue
        self.destinationValue = endValue
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        if duration == 0.0 {
            setTextValue(endValue)
            return;
        }
        
        self.progress = 0
        self.totalTime = duration
        self.lastUpdate = Date().timeIntervalSinceReferenceDate
        
        if self.format == nil {
            self.format = "%f"
        }
        
        self.timer = Timer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(CountingLabel.updateValue(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.UITrackingRunLoopMode)
    }
    
    func countFromCurrentValue(_ endValue: CGFloat, duration: TimeInterval) {
        count(self.currentValue(), endValue: endValue, duration: duration)
    }
    
    func setValueFormat(_ format: String) {
        self.format = format
        setTextValue(self.currentValue())
    }
    
    fileprivate func currentValue() -> CGFloat {
        if self.progress >= self.totalTime {
            return self.destinationValue
        }
        
        let percent = self.progress / self.totalTime
        return self.startingValue + CGFloat(percent) * (self.destinationValue - self.startingValue)
    }
    
    fileprivate func setTextValue(_ value: CGFloat) {
        let cashAmount = String(format: "$%.5f", value)
        let currencyFont = UIFont(name: "HelveticaNeue-Thin", size: 28.0)!
        let decimalFont = UIFont(name: "HelveticaNeue-Thin", size: 28.0)!
        let benefitFont = UIFont(name: "HelveticaNeue-Medium", size: 28.0)!

        guard let dotRange = cashAmount.range(of: ".") else { return }
        let intLength = cashAmount.characters.distance(from: cashAmount.startIndex, to: dotRange.lowerBound) - 1
        
        var nonZeroIndex = intLength + 1
        let nonZeroFound = cashAmount == "$0.00000" ? false : true
        if value >= 0.1 {
            nonZeroIndex = intLength + 2
        } else if value >= 0.01 {
            nonZeroIndex = intLength + 3
        } else if value >= 0.001 {
            nonZeroIndex = intLength + 4
        } else if value >= 0.0001 {
            nonZeroIndex = intLength + 5
        } else if value >= 0.00001 {
            nonZeroIndex = intLength + 6
        } else {
            nonZeroIndex = intLength + 6
        }
        
        let integerColor = value >= 1.0 ? UIColor.defaultBlueColor() : UIColor.defaultDarkGrayColor()
        let dotColor = value >= 1.0 ? UIColor.defaultBlueColor() : UIColor.defaultDarkGrayColor()
        let intFont = value >= 1.0 ? UIFont(name: "HelveticaNeue", size: 50.0)! : UIFont(name: "HelveticaNeue-UltraLight", size: 50.0)!

        let currencyCapHeight = intFont.capHeight - currencyFont.capHeight
        let decimalCapHeight = intFont.capHeight - decimalFont.capHeight
        let benefitCapHeight = intFont.capHeight - benefitFont.capHeight
        
        let localCurrencyCashAmount = cashAmount.replacingOccurrences(of: "$", with: FitVing.sharedInstance.currencySymbol)
        
        
        let attributeText = NSMutableAttributedString(string: localCurrencyCashAmount)
        attributeText.addAttributes([NSFontAttributeName:currencyFont, NSForegroundColorAttributeName:UIColor.defaultDarkGrayColor(), NSBaselineOffsetAttributeName:currencyCapHeight], range: NSMakeRange(0, 1))
        attributeText.addAttributes([NSFontAttributeName:intFont, NSForegroundColorAttributeName:integerColor], range: NSMakeRange(1, intLength))
        attributeText.addAttributes([NSFontAttributeName:decimalFont, NSForegroundColorAttributeName:dotColor, NSBaselineOffsetAttributeName:decimalCapHeight], range: NSMakeRange(intLength + 1, 1))
        attributeText.addAttributes([NSFontAttributeName:decimalFont, NSForegroundColorAttributeName:UIColor.defaultDarkGrayColor(), NSBaselineOffsetAttributeName:decimalCapHeight], range: NSMakeRange(intLength + 2, nonZeroIndex - (intLength + 1)))

        if nonZeroFound {
            attributeText.addAttributes([NSFontAttributeName:benefitFont, NSForegroundColorAttributeName:UIColor.defaultBlueColor(), NSBaselineOffsetAttributeName:benefitCapHeight], range: NSMakeRange(nonZeroIndex, localCurrencyCashAmount.characters.count - nonZeroIndex))
        }
        
                self.attributedText = attributeText

    }
    
    func updateValue(_ timer: Timer) {
        let now = Date().timeIntervalSinceReferenceDate
        self.progress += now - self.lastUpdate
        self.lastUpdate = now
        
        if self.progress >= self.totalTime {
            self.timer?.invalidate()
            self.timer = nil
            self.progress = self.totalTime
        }
        
        self.setTextValue(self.currentValue())
    }
}
