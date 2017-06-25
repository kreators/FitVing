
import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "Help Centers"
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
        
        menuButton.addTarget(self, action: #selector(HelpViewController.menuButtonPressed(_:)), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
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
