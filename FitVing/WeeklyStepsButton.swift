
import UIKit

class WeeklyStepsButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Helpers
    
    fileprivate func commonInit() {
        let shapeLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.bounds.width, y: 0.0))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.bounds.height))
        path.addLine(to: CGPoint(x: self.bounds.width, y: 0.0))
        path.closeSubpath()
        shapeLayer.path = path
        self.layer.masksToBounds = true
        self.layer.mask = shapeLayer
        
        let imageView = UIImageView(image: UIImage(named: "graph"))
        imageView.frame = CGRect(x: self.bounds.width - 15.0 - 31.0, y: self.bounds.height - 9.0 - 23.0, width: 31.0, height: 23.0)
        
        self.addSubview(imageView)
    }
}
