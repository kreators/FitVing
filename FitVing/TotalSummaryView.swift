
import UIKit

class TotalSummaryView: UIView {
    
    let totalDepositValue = UILabel()
    let savingsBonusValue = UILabel()
    let withdrawValue = UILabel()
    let totalBalanceValue = UILabel()
    let totalDepositLabel = UILabel()
    let savingsBonusLabel = UILabel()
    let withdrawLabel = UILabel()
    let totalBalanceLabel = UILabel()
    let seperator = UIView()
    
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
        
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[totalDepositLabel(30)]-[savingsBonusLabel(30)]-[withdrawLabel(30)]-[seperator(1)]-[totalBalanceLabel(30)]-(\(verticalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalDepositLabel":totalDepositLabel, "savingsBonusLabel":savingsBonusLabel, "withdrawLabel":withdrawLabel, "totalBalanceLabel":totalBalanceLabel, "seperator":seperator])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[totalDepositLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalDepositLabel":totalDepositLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[savingsBonusLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["savingsBonusLabel":savingsBonusLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[withdrawLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["withdrawLabel":withdrawLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[totalBalanceLabel]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalBalanceLabel":totalBalanceLabel])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(horizontalPadding))-[seperator]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["seperator":seperator])
        
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[totalDepositValue(30)]-[savingsBonusValue(30)]-[withdrawValue(30)]-(17)-[totalBalanceValue(30)]-(\(verticalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalDepositValue":totalDepositValue, "savingsBonusValue":savingsBonusValue, "withdrawValue":withdrawValue, "totalBalanceValue":totalBalanceValue])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[totalDepositValue(80)]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalDepositValue":totalDepositValue])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[savingsBonusValue(80)]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["savingsBonusValue":savingsBonusValue])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[withdrawValue(80)]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["withdrawValue":withdrawValue])
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[totalBalanceValue(80)]-(\(horizontalPadding))-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["totalBalanceValue":totalBalanceValue])
        
        self.addConstraints(layoutConstraints)
        self.layoutIfNeeded()
    }
    
    fileprivate func commonInit() {
        initUI()
    }
    
    fileprivate func initUI() {
        let fontSize: CGFloat = 16.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        totalDepositLabel.text = "  Total deposit"
        totalDepositLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        totalDepositLabel.textColor = UIColor.grayTextColor()
        self.addSubview(totalDepositLabel)
        
        savingsBonusLabel.text = "+ Savings bonus"
        savingsBonusLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        savingsBonusLabel.textColor = UIColor.grayTextColor()
        self.addSubview(savingsBonusLabel)
        
        withdrawLabel.text = "- Withdraw"
        withdrawLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        withdrawLabel.textColor = UIColor.grayTextColor()
        self.addSubview(withdrawLabel)
        
        seperator.backgroundColor = UIColor.grayTextColor()
        self.addSubview(seperator)
        
        totalBalanceLabel.text = "= Total balance"
        totalBalanceLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        totalBalanceLabel.textColor = UIColor.grayTextColor()
        self.addSubview(totalBalanceLabel)
        
        totalDepositValue.text = ": $0.0"
        totalDepositValue.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        totalDepositValue.textColor = UIColor.grayTextColor()
        self.addSubview(totalDepositValue)
        
        savingsBonusValue.text = ": $0.0"
        savingsBonusValue.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        savingsBonusValue.textColor = UIColor.grayTextColor()
        self.addSubview(savingsBonusValue)
        
        withdrawValue.text = ": $0.0"
        withdrawValue.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        withdrawValue.textColor = UIColor.grayTextColor()
        self.addSubview(withdrawValue)
        
        totalBalanceValue.text = ": $0.0"
        totalBalanceValue.font = UIFont(name: "HelveticaNeue", size: fontSize)!
        totalBalanceValue.textColor = UIColor.grayTextColor()
        self.addSubview(totalBalanceValue)
        
        for v in self.subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func updateSummary() {
        let totalDeposit = FitVing.sharedInstance.totalDeposit()
        let totalWithdraw = FitVing.sharedInstance.totalWithdraw()
        let totalBalance = FitVing.sharedInstance.currentBalance
        let totalSavingBonus = totalBalance + totalWithdraw - totalDeposit
        totalDepositValue.text = ": $\(totalDeposit.printPrecision())"
        savingsBonusValue.text = ": $\(totalSavingBonus.printPrecision())"
        withdrawValue.text = ": $\(totalWithdraw.printPrecision())"
        totalBalanceValue.text = ": $\(totalBalance.printPrecision())"
    }
}
