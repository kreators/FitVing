
import Foundation
import UIKit

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath)
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.textLabel!.text = NSLocalizedString("Set your daily step", comment: "Set your daily step")
        case 1:
            cell.textLabel!.text = NSLocalizedString("Set your daily deposit", comment: "Set your daily deposit")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            self.performSegue(withIdentifier: "targetStepsSegue", sender: nil)
        } else if (indexPath as NSIndexPath).row == 1 {
            self.performSegue(withIdentifier: "depositSegue", sender: nil)
        } else if (indexPath as NSIndexPath).row == 2 {
            self.performSegue(withIdentifier: "syncWearableDevicesSegue", sender: nil)
        }
    }
}
