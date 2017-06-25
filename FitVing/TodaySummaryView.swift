
import UIKit

class TodaySummaryView: UIView {

    let depositLabel = UILabel()
    let interestLabel = UILabel()
    
    var layoutConstraints = [NSLayoutConstraint]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayoutConstraints()
    }
    
    // MARK: - Helpers
    
    fileprivate func setupLayoutConstraints() {
        let verticalPadding = (self.bounds.height - 120.0) / 2.0
        let horizontalPadding = 50.0
        if layoutConstraints.count > 0 {
            self.removeConstraints(layoutConstraints)
            layoutConstraints.removeAll()
        }
        
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(verticalPadding))-[depositLabel(30)]-[interestLabel(30)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["depositLabel":depositLabel, "interestLabel":interestLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[depositLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["depositLabel":depositLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[interestLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["interestLabel":interestLabel])
        
        self.addConstraints(layoutConstraints)
        self.layoutIfNeeded()
    }
    
    fileprivate func commonInit() {
        initUI()
    }
    
    fileprivate func initUI() {
        let fontSize: CGFloat = 20.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        depositLabel.text = "Today's Deposit : $0.0"
        depositLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        depositLabel.textColor = UIColor.grayTextColor()
        self.addSubview(depositLabel)
        
        interestLabel.text = "Interest on APY 0.0%"
        interestLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        interestLabel.textColor = UIColor.grayTextColor()
        self.addSubview(interestLabel)
        
        for v in self.subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func updateSummary() {
        let todayDeposit = FitVing.sharedInstance.todayDeposit()
        depositLabel.text = "Today's Deposit : $\(todayDeposit.printPrecision())"
        let interestRate = FitVing.sharedInstance.interestRateAPY(interestRate: FitVing.sharedInstance.currentInterestRate)
        interestLabel.text = "Interest on APY \(interestRate.printPrecision())%"
    }
}
