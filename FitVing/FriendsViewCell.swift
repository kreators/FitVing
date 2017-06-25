
import UIKit

class FriendsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendTurtleView: FriendsTurtleView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    // MARK: - Helpers
    
    fileprivate func commonInit() {
        friendLabel.text = "Jane K"
        friendLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
        friendLabel.textColor = UIColor.defaultDarkGrayColor()
        friendLabel.textAlignment = .center

        stepsLabel.text = "0"
        stepsLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
        stepsLabel.textColor = UIColor.defaultBlueColor()
        stepsLabel.textAlignment = .center
        
        friendTurtleView.progress = 0.46
    }
}
