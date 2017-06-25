
import UIKit

class MyAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 58.0/255.0, green: 180.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        self.navigationItem.title = "My Account"
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
        
        menuButton.addTarget(self, action: #selector(SettingsViewController.menuButtonPressed(_:)), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath)
        switch (indexPath as NSIndexPath).row {
        default:
            cell.textLabel!.text = NSLocalizedString("Transfer to Bank", comment: "Transfer to Bank")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            self.performSegue(withIdentifier: "transferInputAmountSegue", sender: nil)
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "targetStepsSegue" {
            let vc = segue.destination as! StepTargetViewController
            vc.fromSettings = true
        } else if segue.identifier == "depositSegue" {
            let vc = segue.destination as! DepositViewController
            vc.fromSettings = true
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
    }
}
