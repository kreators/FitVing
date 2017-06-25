
import UIKit
import CoreLocation
import CoreMotion
import Alamofire

class HomeViewController: UIViewController, CLLocationManagerDelegate, ManualDepositViewControllerDelegate, DepositViewControllerDelegate, StepTargetViewControllerDelegate, GMSMapViewDelegate, Alertable {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var turtleView: TurtleView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var friendsView: FriendsView!
    @IBOutlet weak var weeklyStepsView: WeeklyStepsView!
    
    @IBOutlet weak var friendsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var weeklyStepsViewConstraint: NSLayoutConstraint!
    
    let healthManager = HealthManager()
    
    let pedoMeter = CMPedometer()
    fileprivate let serialQueue = DispatchQueue(label: "com.tortoise.queue", attributes: [])
    
    fileprivate var facebookFriends = [Dictionary<String, String>]()
    
    var locationManager = CLLocationManager()
    
    var didFindMyLocation = false
    var targetSteps: Int = 0
    var currentSteps = 0.0
    var targetDeposit = 0.0
    fileprivate var manualDeposit = 0.0
    fileprivate var lastBalance: Double?
    
    fileprivate var resetTimer: Timer?
    fileprivate var resetTimerCreated: Date?
    fileprivate var checkTimer: Timer?
    fileprivate var lastDailyBalnaceDate: Date?
    fileprivate var cloudUploadNeeded = false
    
    var calculatedCashAmount = 0.0
    var calculatedInterestAmount = 0.0
    
    var introShowed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        FitVing.sharedInstance.valuesInitialized = false
        
        initUI()
        FitVing.sharedInstance.homeViewController = self

        /*
        if self.checkRequiredValues() == false {
            self.rebuildRequiredValues()
        }
        print("targetSteps : \(self.targetSteps) targetDeposit : \(self.targetDeposit), lastBalance : \(self.lastBalance)")
 */
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        initNotifications()
    }
    
    fileprivate func checkRequiredValues() -> Bool {
        let now = Date.Now()
        self.targetSteps = FitVing.sharedInstance.targetSteps(at: now)
        self.targetDeposit = FitVing.sharedInstance.targetDeposit(at: now)
        self.manualDeposit = FitVing.sharedInstance.manualDeposit(at: now)
        self.lastDailyBalnaceDate = FitVing.sharedInstance.lastDailyBalanceDate()
        self.lastBalance = FitVing.sharedInstance.readYesterdayBalance()
        guard self.targetSteps > 0, self.targetDeposit > 0.0, let _ = self.lastBalance else { return false }
        return true
    }
    
    fileprivate func rebuildRequiredValues() {
        FitVing.sharedInstance.lastdailybalancesAtCloud()
        serialQueue.async {
            FitVing.sharedInstance.serialSemaphore.wait()
            FitVing.sharedInstance.serialSemaphore.signal()
            FitVing.sharedInstance.processDailyBalances()
            FitVing.sharedInstance.valuesInitialized = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = FitVing.sharedInstance.tortoiseUserId, let _ = FitVing.sharedInstance.SPUserId {
            if self.checkRequiredValues() == false {
                self.rebuildRequiredValues()
            } else {
                FitVing.sharedInstance.valuesInitialized = true
            }
            loadHealthKit()
            loadPedometer()
            initTimers()
        } else {
            FitVing.sharedInstance.eraseTortoiseData()
            self.performSegue(withIdentifier: "accountSetupSegue", sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deinitTimers()
        self.pedoMeter.stopUpdates()
    }
    
    fileprivate func lastdailybalance() {
        return;
        let params = ["id":"111", "amount":"111", "currency":"USD"]
        print("START11111")
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/lastdailybalance", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
                print("============ lastdailybalance ============")
                debugPrint(response.result)
                if let JSON = response.result.value as? [String:Any] {
                    print("JSON: \(JSON)")
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            print("success")
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }
    }

    fileprivate func updatedailybalance() {
        return;
        guard let SPUserId = FitVing.sharedInstance.SPUserId, let SPBankId = FitVing.sharedInstance.SPBankId else { return }
        let params = ["id":SPUserId, "dailyDeposit":"0.123", "dailyInterest":"0.345", "dailyPrincipal":"1.01", "dailyBalance":"12.123456789", "dateApplied":"2017-03-28 12:34:56", "timezone":TimeZone.current.identifier]
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/updatedailybalance", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value as? [String:Any] {
                if let result = JSON["result"] as? String {
                    if result == "success" {
                    }
                } else {
                    self.showErrorAlert(self)
                }
            } else {
                self.showErrorAlert(self)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        return;

//        lastdailybalance()
//        updatedailybalance()
        

/* required */
        print(FitVing.sharedInstance.tortoiseUserId, FitVing.sharedInstance.tortoiseUserEmail, FitVing.sharedInstance.SPUserId)
        if let _ = FitVing.sharedInstance.tortoiseUserId, let _ = FitVing.sharedInstance.SPUserId {
        } else {
            self.performSegue(withIdentifier: "accountSetupSegue", sender: self)
        }
        /*
introShowed = true
        if introShowed == false {
            introShowed = true
            print("@@@@@@")
            self.performSegue(withIdentifier: "accountSetupSegue", sender: self)
        }
 

        //      FBSDKLoginManager().logOut()
        if (FBSDKAccessToken.current() != nil) {
            returnUserData()
            self.requestFacebookFriends()
        } else {
            self.performSegue(withIdentifier: "accountSetupSegue", sender: self)
        }
 */
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        else if status == CLAuthorizationStatus.denied {
            print("Denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        mapView.camera = GMSCameraPosition.camera(withTarget: (location?.coordinate)!, zoom: 16.0)
    }
    
    // MARK: - Timer
    
    func resetTurtleView(_ timer: Timer) {
        guard FitVing.sharedInstance.valuesInitialized else { return }
        guard let createdAt = self.resetTimerCreated else { return }

        if FitVing.sharedInstance.isSameday(createdAt, from: Date.Now()) == false {
            self.resetTimerCreated = Date.Now()
            self.turtleView.progress = 0.0
            self.turtleView.currentSteps = 0
            DispatchQueue.main.async(execute: { () -> Void in
                self.turtleView.setNeedsDisplay()
            })
            self.pedoMeter.stopUpdates()
            self.loadPedometer()
        }
    }
    
    func checkProcessDailyBalanceNeeded(_ timer: Timer) {
        guard FitVing.sharedInstance.valuesInitialized else { return }
        if let lastDailyBalanceDate = self.lastDailyBalnaceDate {
            if FitVing.sharedInstance.isYesterday(lastDailyBalanceDate, from: Date.Now()) == false {
                FitVing.sharedInstance.processDailyBalances()
            }
        }
    }

    // MARK: - Helpers
    
    fileprivate func initNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProcessDailyBalancesCompleted"), object: nil, queue: OperationQueue.main) { (notification) in
            self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(self.currentSteps))
            if self.cloudUploadNeeded {
                self.uploadDailyBalances()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "HealthKitAuthorized"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.loadHealthKit()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "InfoPressed"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.performSegue(withIdentifier: "showInformation", sender: self)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProfileImageUpdated"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            if let userId = FitVing.sharedInstance.facebookUserId {
                self.profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
            } else {
                self.profileImageView.image = UIImage(named: "ProfileImage")
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StepTargetRequired"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.performSegue(withIdentifier: "showStepTarget", sender: self)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DepositRequired"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.performSegue(withIdentifier: "showManualDeposit", sender: self)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "transferToBankRequested"), object: nil, queue: OperationQueue.main) { (notification) in
            if let userInfo = notification.userInfo as? [String:Any] {
                if let amountString = userInfo["amount"] as? String {
                    if let amount = Double(amountString) {
                        self.depositAdded(-amount)
                        
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UIApplicationDidEnterBackgroundNotification"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.deinitTimers()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.initTimers()
        }
    }

    fileprivate func initTimers() {
        self.resetTimerCreated = Date.Now()
        if self.resetTimer == nil {
            self.resetTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.resetTurtleView(_:)), userInfo: nil, repeats: true)
        }
        if self.checkTimer == nil {
            self.checkTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.checkProcessDailyBalanceNeeded(_:)), userInfo: nil, repeats: true)
            self.checkProcessDailyBalanceNeeded(self.checkTimer!)
        }
    }
    
    fileprivate func deinitTimers() {
        if let resetTimer = self.resetTimer {
            resetTimer.invalidate()
            self.resetTimer = nil
        }
        self.resetTimerCreated = nil
        if let checkTimer = self.checkTimer {
            checkTimer.invalidate()
            self.checkTimer = nil
        }
    }
    
    
    func uploadDailyBalances() {
        return;
//        guard let userId = FitVing.sharedInstance.userId else { return }
        let userId = "222"
        let dailyBalances = FitVing.sharedInstance.last100DailyBalances()
        guard dailyBalances.count > 0 else { return }
        
        let params = ["id":userId, "dailyBalances":dailyBalances] as [String : Any]
        print("\(#function) START")
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/updatedailybalances", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
                print("============ \(#function) ============")
                debugPrint(response.result)
                if let JSON = response.result.value as? [String:Any] {
                    print("JSON: \(JSON)")
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            print("success")
                        }
                    } else {
                        self.showErrorAlert(self)
                    }
                }
        }

        
    }

    fileprivate func requestFacebookFriends() {
        let params = ["fields":"id,name"]
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params, httpMethod: "GET")
        request?.start { (connection, result, error) -> Void in
            self.facebookFriends.removeAll()
            guard let graphResult = result as? [String:Any?] else { return }

            if let data = graphResult["data"] as? [Dictionary<String, String>] {
                for friend in data {
                    self.facebookFriends.append(friend)
                }
            }
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark) {
        if let locality = placemark.locality {
            FitVing.sharedInstance.currentLocality = locality
            if let administrativeArea = placemark.administrativeArea {
                FitVing.sharedInstance.currentLocality = locality + ", " + administrativeArea
            }
        }
    }

    fileprivate func updateSteps() {
        guard let facebookUserId = FitVing.sharedInstance.facebookUserId else { return }
        let currentSteps = Int(self.currentSteps)
        let params = ["facebookId":facebookUserId, "currentSteps":String(currentSteps), "targetSteps":String(targetSteps)]
        serialQueue.async { () -> Void in
            Alamofire.request("https://gateway.tinyvect0r.com/api/v1/updatefriendsteps", method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    if let JSON = response.result.value {
                    }
            }
        }
    }
    
    fileprivate func loadPedometer() {
        var cal = Calendar.current
        var comps = (cal as NSCalendar).components([.year, .month, .day], from: Date.Now())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        cal.timeZone = TimeZone.current
        
        let midnightOfToday = cal.date(from: comps)!
        
        if CMPedometer.isStepCountingAvailable() {
            self.pedoMeter.startUpdates(from: midnightOfToday, withHandler: { (data, error) -> Void in
                guard self.targetSteps > 0 else { return }
                guard self.targetDeposit > 0.0 else { return }
                guard let pedometerData = data else { return }
                guard pedometerData.endDate.timeIntervalSince(pedometerData.startDate) < 86400 else { return }

                self.turtleView.progress = Double(pedometerData.numberOfSteps) / Double(self.targetSteps)
                if self.turtleView.progress > 1.0 {
                    self.turtleView.progress = 1.0
                }
                self.currentSteps = Double(data!.numberOfSteps)
                self.turtleView.currentSteps = Int(self.currentSteps)
                self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(self.currentSteps))
                self.turtleView.currentCash = CGFloat(self.calculateCashAmount(self.currentSteps))
                DispatchQueue.main.async(execute: { () -> Void in
                    self.turtleView.setNeedsDisplay()
                })
                self.updateSteps()
            })
        }

    }
    
    fileprivate func loadHealthKit() {
        guard FitVing.sharedInstance.valuesInitialized else { return }
        if healthManager.checkAuthorization() == true {
            FitVing.sharedInstance.checkDailyBalances()
            healthManager.observeStepCount() {
                (steps) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.turtleView.progress = Double(steps)! / Double(self.targetSteps)
                    if self.turtleView.progress > 1.0 {
                        self.turtleView.progress = 1.0
                    }
                                    self.currentSteps = Double(steps)!
                    self.turtleView.currentSteps = Int(self.currentSteps)
                    self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(self.currentSteps))
                    self.turtleView.currentCash = CGFloat(self.calculateCashAmount(self.currentSteps))

                    DispatchQueue.main.async(execute: { () -> Void in
                        self.turtleView.setNeedsDisplay()
                    })
                    self.updateSteps()
                })
            }
        }
    }
    
    fileprivate func calculateCashAmount(_ steps: Double) -> Double {
        guard FitVing.sharedInstance.valuesInitialized == true else { return 0.0 }
        self.targetSteps = FitVing.sharedInstance.targetSteps(at: Date.Now())
        self.targetDeposit = FitVing.sharedInstance.targetDeposit(at: Date.Now())
        self.manualDeposit = FitVing.sharedInstance.manualDeposit(at: Date.Now())
        self.lastBalance = FitVing.sharedInstance.readYesterdayBalance()
        if let lastBalance = self.lastBalance {
            let amount = FitVing.sharedInstance.calculateCashAmount(self.targetDeposit, manualDepositAmount: self.manualDeposit, lastBalance: lastBalance, targetSteps: self.targetSteps, steps: steps)
            self.calculatedCashAmount = amount
            self.calculatedInterestAmount = FitVing.sharedInstance.calculateCashAmount(self.targetDeposit, manualDepositAmount: self.manualDeposit, lastBalance: lastBalance, targetSteps: self.targetSteps, steps: steps)
            return self.calculatedCashAmount
        }
        return 0.0
    }

    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        let titleImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 123.0, height: 17.0))
        titleImageView.image = UIImage(named: "tortoise2.3")
        self.navigationItem.titleView = titleImageView
        
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2.0
        self.profileImageView.clipsToBounds = true
        self.profileImageView.isHidden = true
        
        let menuButton = UIButton(type: .custom)
        menuButton.frame = CGRect(x: 0.0, y: 0.0, width: 23.0, height: 17.0)
        menuButton.setImage(UIImage(named: "Hamburger"), for: UIControlState())
        menuButton.addTarget(self, action: #selector(HomeViewController.menuButtonPressed(_:)), for: .touchUpInside)

        let leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem

        let depositButton = UIButton(type: .custom)
        depositButton.frame = CGRect(x: 0.0, y: 0.0, width: 21.0, height: 26.0)
        depositButton.setImage(UIImage(named: "deposit"), for: UIControlState())
        depositButton.addTarget(self, action: #selector(HomeViewController.depositButtonPressed(_:)), for: .touchUpInside)

        let rightBarButtonItem = UIBarButtonItem(customView: depositButton)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 17.0)
        mapView.camera = camera

        mapView.padding = UIEdgeInsetsMake(65.0, 0.0, 65.0, 0.0)
        
        blurImageView.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
    }
    
    // MARK: - ManualDepositViewControllerDelegate
    
    func depositAdded(_ deposit: Double) {
        FitVing.sharedInstance.addManualDeposit(deposit, date: Date.Now())
        self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(currentSteps))
    }

    // MARK: - DepositViewControllerDelegate
    
    func depositChanged(_ deposit: Double) {
        FitVing.sharedInstance.addTargetDeposit(deposit, date: Date.Now())
        self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(currentSteps))
    }

    // MARK: - StepTargetViewControllerDelegate
    
    func stepTargetChanged(_ stepTarget: Int) {
        FitVing.sharedInstance.addTargetSteps(stepTarget, date: Date.Now())
        self.turtleView.cashAmount = String(format: "$%.5f", self.calculateCashAmount(currentSteps))
    }

    // MARK: - Actions
    
    @IBAction func friendsPressed(_ sender: UIButton) {
        FitVing.sharedInstance.flurryLogEvent("MainFriend")
        self.friendsViewConstraint.constant = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finish) -> Void in
                self.friendsView.updateSteps()
        })
    }
    
    @IBAction func friendsViewTapped(_ recognizer: UITapGestureRecognizer) {
        self.friendsViewConstraint.constant = 150.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finish) -> Void in
        })
    }
    
    @IBAction func weeklyStepsPressed(_ sender: UIButton) {
        FitVing.sharedInstance.flurryLogEvent("MainWeek")
        self.weeklyStepsViewConstraint.constant = 0.0
        self.weeklyStepsView.setNeedsDisplay()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func weeklyStepsViewTapped(_ recognizer: UITapGestureRecognizer) {
        self.weeklyStepsViewConstraint.constant = 150.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    func menuButtonPressed(_ sender: UIButton) {
          FitVing.sharedInstance.flurryLogEvent("MainMenu")
        if let drawerController = self.tabBarController?.parent as? KYDrawerController {
            if drawerController.drawerState == .opened {
                drawerController.setDrawerState(.closed, animated: true)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "MenuWillShow"), object: nil)
                drawerController.setDrawerState(.opened, animated: true)
            }
        }
    }
    
    func depositButtonPressed(_ sender: UIButton) {
        FitVing.sharedInstance.flurryLogEvent("MainDeposit")
        self.performSegue(withIdentifier: "showManualDeposit", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showManualDeposit" {
            let vc = segue.destination as! ManualDepositViewController
            vc.delegate = self
        } else if segue.identifier == "showStepTarget" {
            let vc = segue.destination as! StepTargetViewController
            vc.delegate = self
        }
    }
}

