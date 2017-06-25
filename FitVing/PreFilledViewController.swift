
import UIKit

protocol PreFilledViewControllerDelegate {
    func numberChanged(_ numberInput: String, description: String)
}

class PreFilledViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: PreFilledViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCell
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.imageView.image = UIImage(named: "taxi")
        case 1:
            cell.imageView.image = UIImage(named: "sweets")
        case 2:
            cell.imageView.image = UIImage(named: "beer")
        case 3:
            cell.imageView.image = UIImage(named: "soda")
        case 4:
            cell.imageView.image = UIImage(named: "coffee")
        case 5:
            cell.imageView.image = UIImage(named: "cigarette")
        case 6:
            cell.imageView.image = UIImage(named: "fastfood")
        case 7:
            cell.imageView.image = UIImage(named: "chips")
        default:
            cell.imageView.image = nil
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.view.bounds.size.width / 3.0
        let cellHeight = cellWidth * 0.68
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var numberPreFilled = 0.0
        var description = "Instead of catching a cab"
        switch (indexPath as NSIndexPath).row {
        case 0:
            numberPreFilled = 15.0
            description = "Instead of\n catching a cab"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityTaxi")
        case 1:
            numberPreFilled = 1.2
            description = "Instead of\n sweets"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityCandy")
        case 2:
            numberPreFilled = 9.0
            description = "Instead of\n a glass of beer"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityBeer")
        case 3:
            numberPreFilled = 1.5
            description = "Instead of\n a can of soda"
            FitVing.sharedInstance.flurryLogEvent("DepositActivitySoda")
        case 4:
            numberPreFilled = 3.45
            description = "Instead of\n a cup of coffee"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityCoffee")
        case 5:
            numberPreFilled = 14.5
            description = "Instead of\n a pack of cigarettes"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityCigarette")
        case 6:
            numberPreFilled = 4.0
            description = "Instead of\n a hamburger"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityBurger")
        case 7:
            numberPreFilled = 2.5
            description = "Instead of\n a bag of chips"
            FitVing.sharedInstance.flurryLogEvent("DepositActivityChips")
        default:
            numberPreFilled = 0.0
            description = "?"
        }

        if let delegate = self.delegate {
            let numberPreFilledString = String(numberPreFilled)
            if numberPreFilledString.contains(".0") {
                delegate.numberChanged(String(Int(numberPreFilled)), description: description)
            }
            else {
                delegate.numberChanged(numberPreFilledString, description: description)
            }
        }
    }
}
