
import UIKit
import AlamofireImage

class MenuViewController: UIViewController {

    let profileImageView = UIImageView(frame: CGRect(x: 20.0, y: 45.0, width: 40.0, height: 40.0))
    let nameLabel = UILabel()
    let locationLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProfileImageUpdated"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            if let userId = FitVing.sharedInstance.facebookUserId {
                self.profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
                if let username = FitVing.sharedInstance.facebookUsername {
                    self.nameLabel.text = username
                }
            } else {
                self.profileImageView.image = UIImage(named: "ProfileImage")
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "MenuWillShow"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.locationLabel.text = FitVing.sharedInstance.currentLocality // "Livingston, NJ"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.view.backgroundColor = UIColor(red: 114.0/255.0, green: 112.0/255.0, blue: 113.0/255.0, alpha: 1.0)

        if let userId = FitVing.sharedInstance.facebookUserId {
            profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
        } else {
            profileImageView.image = UIImage(named: "ProfileImage")
        }
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2.0
        self.profileImageView.clipsToBounds = true
        self.view.addSubview(profileImageView)
        
        nameLabel.frame = CGRect(x: 70.0, y: 44.0, width: self.view.bounds.size.width / 2.0 - 70.0 - 10.0, height: 20.0)
        if let username = FitVing.sharedInstance.facebookUsername {
            nameLabel.text = username
        } else {
            nameLabel.text = "Tortoise"
        }
        nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        nameLabel.textColor = UIColor.white
        self.view.addSubview(nameLabel)

        locationLabel.frame = CGRect(x: 70.0, y: 64.0, width: self.view.bounds.size.width / 2.0 - 70.0 - 10.0, height: 20.0)
        locationLabel.text = FitVing.sharedInstance.currentLocality // "Livingston, NJ"
        locationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        locationLabel.textColor = UIColor.white
        self.view.addSubview(locationLabel)

        for (index, element) in ["Home", "My Account", "History", "Help Centers", "Settings"].enumerated() {
            let imageButton = UIButton(frame: CGRect(x: 10.0, y: 135.0 + CGFloat(index) * 50.0, width: 40.0, height: 40.0))
            switch index {
            case 0:
                imageButton.setImage(UIImage(named: "home"), for: UIControlState())
            case 1:
                imageButton.setImage(UIImage(named: "invite-friends"), for: UIControlState())
            case 2:
                imageButton.setImage(UIImage(named: "history"), for: UIControlState())
            case 3:
                imageButton.setImage(UIImage(named: "help-centers"), for: UIControlState())
            default:
                imageButton.setImage(UIImage(named: "settings"), for: UIControlState())
            }
            imageButton.contentHorizontalAlignment = .center
            imageButton.tag = index
            imageButton.addTarget(self, action: #selector(MenuViewController.buttonPressed(_:)), for: .touchUpInside)
            self.view.addSubview(imageButton)
            
            let button = UIButton(frame: CGRect(x: 50.0, y: 135.0 + CGFloat(index) * 50.0, width: self.view.bounds.size.width / 2.0 - 10.0 - 50.0, height: 40.0))
            let menuString = NSLocalizedString(element, comment: "Menu String")
            button.setTitle(menuString, for: UIControlState())
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
            button.contentHorizontalAlignment = .left
            button.tag = index
            button.addTarget(self, action: #selector(MenuViewController.buttonPressed(_:)), for: .touchUpInside)
            self.view.addSubview(button)
        }

    }
    
    func buttonPressed(_ sender: UIButton) {
        let drawerController = self.parent as! KYDrawerController
        drawerController.setDrawerState(.closed, animated: true)
        let tabBarController = drawerController.mainViewController as! UITabBarController
        switch sender.tag {
        case 0:
            FitVing.sharedInstance.flurryLogEvent("MenuHome")
            tabBarController.selectedIndex = 0
        case 1:
            FitVing.sharedInstance.flurryLogEvent("MenuMyAccount")
            tabBarController.selectedIndex = 5
        case 2:
            FitVing.sharedInstance.flurryLogEvent("MenuHistory")
            tabBarController.selectedIndex = 1
        case 3:
            FitVing.sharedInstance.flurryLogEvent("MenuHelp")
            tabBarController.selectedIndex = 4
        default:
            FitVing.sharedInstance.flurryLogEvent("MenuSettings")
            tabBarController.selectedIndex = 2
        }
    }
}
