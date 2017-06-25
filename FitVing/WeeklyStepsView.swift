
import UIKit

class WeeklyStepsView: UIView {
    
    let dayBars = [UIView(), UIView(), UIView(), UIView(), UIView(), UIView(), UIView()]
    let dayLabels = [UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel()]
    let dayBarsBottomY: CGFloat = 150.0 - 10.0 - 13.0
    let dayBarHeight: CGFloat = 10.0
    let dayBarMaxHeight: CGFloat = 90.0
    let healthManager = HealthManager()
    
    var daySteps = [3200, 7211, 5300, 9592, 15000, 3200, 7211]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        healthManager.stepsLast7Days() { (daySteps, error) -> Void in
            for index in 0 ... 6 {
                        let spaceOfDays = UIScreen.main.bounds.size.width / 15.0
                let steps = CGFloat(daySteps[index]) > 10000.0 ? 10000.0 : CGFloat(daySteps[index])
                let barHeight = self.dayBarMaxHeight * steps / 10000.0
                self.dayBars[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: self.dayBarsBottomY - barHeight, width: spaceOfDays, height: barHeight)
                self.dayLabels[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: self.dayBarsBottomY - barHeight - 14.0, width: spaceOfDays, height: 9.0)
                self.dayLabels[index].textColor = UIColor.defaultBlueColor()
                self.dayLabels[index].text = String(Int(daySteps[index]))
            }
        }
    }
    
    // MARK: - Helpers
    
    func setup() {
        let textLabel = UILabel()
        textLabel.text = "WEEKLY STEP"
        textLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
        textLabel.textColor = UIColor.defaultDarkGrayColor()
        textLabel.textAlignment = .left
        textLabel.frame = CGRect(x: 25.0, y: 15.0, width: 100.0, height: 10.0)
        self.addSubview(textLabel)
        
        let spaceOfDays = UIScreen.main.bounds.size.width / 15.0
        let days = [["Mon", "Tue", "Wed", "Thurs", "Fri", "Sat", "Sun"],
            ["Tue", "Wed", "Thurs", "Fri", "Sat", "Sun", "Mon"],
            ["Wed", "Thurs", "Fri", "Sat", "Sun", "Mon", "Tue"],
            ["Thurs", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed"],
            ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thurs"],
            ["Sat", "Sun", "Mon", "Tue", "Wed", "Thurs", "Fri"],
            ["Sun", "Mon", "Tue", "Wed", "Thurs", "Fri", "Sat"],
        ]

        let todayComponent = (Calendar.current as NSCalendar).components([.weekday], from: Date())
        let weekday = todayComponent.weekday
        for index in 0 ... 6 {
            let dayLabel = UILabel()
            dayLabel.frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: self.bounds.size.height - 10.0 - 10.0, width: spaceOfDays, height: 10.0)
            let dayOfWeek = days[weekday! - 1][index]
                dayLabel.text = NSLocalizedString(dayOfWeek, comment: "DayOfWeek")
            dayLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
            dayLabel.textColor = UIColor.defaultDarkGrayColor()
            dayLabel.textAlignment = .center
            dayLabel.adjustsFontSizeToFitWidth = true
            self.addSubview(dayLabel)
            
            let steps = CGFloat(daySteps[index]) > 10000.0 ? 10000.0 : CGFloat(daySteps[index])
            let barHeight = self.dayBarMaxHeight * steps / 10000.0
            dayBars[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: dayBarsBottomY - barHeight, width: spaceOfDays, height: barHeight)
            dayBars[index].backgroundColor = UIColor.defaultYellowColor()
            self.addSubview(dayBars[index])

            dayLabels[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: dayBarsBottomY - barHeight - 14.0, width: spaceOfDays, height: 10.0)
            dayLabels[index].textColor = UIColor.defaultBlueColor()
            dayLabels[index].text = String(daySteps[index])
            dayLabels[index].font = UIFont(name: "HelveticaNeue", size: 10.0)
            dayLabels[index].textAlignment = .center
                        dayLabels[index].adjustsFontSizeToFitWidth = true
            self.addSubview(dayLabels[index])
        }
        
        healthManager.stepsLast7Days() { (daySteps, error) -> Void in
            for index in 0 ... 6 {
                let spaceOfDays = UIScreen.main.bounds.size.width / 15.0
                let steps = CGFloat(daySteps[index]) > 10000.0 ? 10000.0 : CGFloat(daySteps[index])
                let barHeight = self.dayBarMaxHeight * steps / 10000.0
                self.dayBars[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: self.dayBarsBottomY - barHeight, width: spaceOfDays, height: barHeight)
                self.dayLabels[index].frame = CGRect(x: spaceOfDays + spaceOfDays * 2.0 * CGFloat(index), y: self.dayBarsBottomY - barHeight - 14.0, width: spaceOfDays, height: 10.0)
                self.dayLabels[index].textColor = UIColor.defaultBlueColor()
                self.dayLabels[index].text = String(Int(daySteps[index]))
            }
        }
    }
}
