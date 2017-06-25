
import UIKit

class FriendsButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Helpers
    
    fileprivate func commonInit() {
        let shapeLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.bounds.height))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.closeSubpath()
        shapeLayer.path = path
        self.layer.masksToBounds = true
        self.layer.mask = shapeLayer
        
        let imageView = UIImageView(image: UIImage(named: "friends"))
        imageView.frame = CGRect(x: 15.0, y: self.bounds.height - 9.0 - 25.0, width: 27.0, height: 25.0)
        
        self.addSubview(imageView)
      }
}
