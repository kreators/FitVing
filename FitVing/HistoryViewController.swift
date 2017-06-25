
import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak fileprivate var segmentView: SegmentView!
    
    @IBOutlet weak fileprivate var todaySummaryView: TodaySummaryView!
    @IBOutlet weak fileprivate var totalSummaryView: TotalSummaryView!
    @IBOutlet weak fileprivate var dayGraphView: UIView! {
        didSet {
            dayGraphView.backgroundColor = UIColor.defaultBlueColor()
        }
    }
    @IBOutlet weak fileprivate var monthGraphView: UIView! {
        didSet {
            monthGraphView.backgroundColor = UIColor.defaultBlueColor()
        }
    }
    @IBOutlet weak fileprivate var leadingLayoutConstraint: NSLayoutConstraint!
    
    fileprivate let dayGraph = LineChart()
    fileprivate let monthGraph = LineChart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProcessDailyBalancesCompleted"), object: nil, queue: OperationQueue.main) { (notification) in
            self.drawLast30DaysGraph()
            self.updateTotalSummary()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateHistory()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "History"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        
        let menuButton = UIButton(type: .custom)
        menuButton.frame = CGRect(x: 0.0, y: 0.0, width: 23.0, height: 17.0)
        menuButton.setImage(UIImage(named: "Hamburger"), for: UIControlState())

        menuButton.addTarget(self, action: #selector(HistoryViewController.menuButtonPressed(_:)), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        FitVing.sharedInstance.flurryLogEvent("MenuHistoryToday")

        
        self.segmentView.setSegments([NSLocalizedString("TODAY", comment: "TODAY"), NSLocalizedString("TOTAL", comment: "TOTAL")]) { (index) -> Void in
            if index == 0 {
                FitVing.sharedInstance.flurryLogEvent("MenuHistoryToday")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.leadingLayoutConstraint.constant = 0.0
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                })
            } else {
                FitVing.sharedInstance.flurryLogEvent("MenuHistoryLast30Days")
                DispatchQueue.main.async(execute: { () -> Void in
                    self.leadingLayoutConstraint.constant = -self.view.bounds.width
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                })
            }
        }
    }
    
    fileprivate func calcTodayAmount(_ steps: [CGFloat]) -> [CGFloat] {
        let targetDeposit = FitVing.sharedInstance.targetDeposit(at: Date.Now())
        let targetSteps = FitVing.sharedInstance.targetSteps(at: Date.Now())
        let principal = FitVing.sharedInstance.currentPrincipal
        let manualDeposit = FitVing.sharedInstance.manualDeposit(at: Date.Now())
        var amounts = [CGFloat]()
        var stepCumulative = 0.0
        for step in steps {
            stepCumulative += Double(step)
            let amount = FitVing.sharedInstance.calculateCashAmount(targetDeposit, manualDepositAmount: manualDeposit, lastBalance: principal, targetSteps: targetSteps, steps: stepCumulative, skipUpdate: true)
            amounts.append(CGFloat(amount))
        }
        return amounts

    }

    fileprivate func updateTodaySummary(_ steps: [CGFloat]) {
        todaySummaryView.updateSummary()
    }


    fileprivate func calcLast30DaysBalances() -> [CGFloat] {
        return FitVing.sharedInstance.last30DayBalances()
    }
    
    fileprivate func updateTotalSummary() {
        totalSummaryView.updateSummary()
    }


    fileprivate func drawTodayGraph(_ steps: [CGFloat]) {
        self.dayGraph.clearAll()
        self.dayGraph.frame = self.dayGraphView.bounds
        self.dayGraph.animation.enabled = true
        self.dayGraph.area = false
        self.dayGraph.x.labels.visible = false
        self.dayGraph.x.grid.visible = false
        self.dayGraph.x.axis.visible = false
        self.dayGraph.y.axis.visible = false
        self.dayGraph.y.labels.visible = false
        self.dayGraph.colors = [UIColor.white]
        self.dayGraph.dots.outerRadius = 8.0
        self.dayGraph.addLine(self.calcTodayAmount(steps))
        DispatchQueue.main.async(execute: {
            self.dayGraphView.addSubview(self.dayGraph)
            self.dayGraph.setNeedsDisplay()
        })
    }
    
    fileprivate func drawLast30DaysGraph() {
        self.monthGraph.clearAll()
        self.monthGraph.frame = self.monthGraphView.bounds
        self.monthGraph.animation.enabled = true
        self.monthGraph.area = false
        self.monthGraph.x.labels.visible = false
        self.monthGraph.x.grid.visible = false
        self.monthGraph.x.axis.visible = false
        self.monthGraph.y.axis.visible = false
        self.monthGraph.y.labels.visible = false
        self.monthGraph.colors = [UIColor.white]
        self.monthGraph.dots.outerRadius = 8.0
        self.monthGraph.addLine(self.calcLast30DaysBalances())
        DispatchQueue.main.async(execute: {
            self.monthGraphView.addSubview(self.monthGraph)
            self.monthGraph.setNeedsDisplay()
        })
    }

    fileprivate func updateHistory() {
        let healthManager = HealthManager()
        healthManager.stepsTodayHourInterval { (stepsHourInterval) in
            if let steps = stepsHourInterval {
                DispatchQueue.main.async {
                    self.drawTodayGraph(steps)
                    self.updateTodaySummary(steps)
                }
            }
        }
        
        if let _ = FitVing.sharedInstance.readYesterdayBalance() {
            self.drawLast30DaysGraph()
            self.updateTotalSummary()
        } else {
            FitVing.sharedInstance.processDailyBalances()
        }
    }
    
    // MARK: - Actions
    
    func menuButtonPressed(_ sender: UIButton) {
        if let drawerController = self.tabBarController?.parent as? KYDrawerController {
            if drawerController.drawerState == .opened {
                drawerController.setDrawerState(.closed, animated: true)
            }
            else {
                drawerController.setDrawerState(.opened, animated: true)
            }
        }
    }
}
