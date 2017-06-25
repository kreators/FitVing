
import UIKit

class TurtleView: UIView {
    
    fileprivate let cashLabel = CountingLabel()
    fileprivate let currentStepsIndicator = UIView()
    fileprivate let currentStepsLabel = UILabel()
    fileprivate let numberFormatter = NumberFormatter()
    fileprivate let profileImageView = UIImageView()
    fileprivate var currentStepsLabelPoint: CGPoint = CGPoint.zero

    var progress = 0.0
    var cashAmount = "$5.000"
    var currentSteps = 0
    var currentCash: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProfileImageUpdated"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            if let userId = FitVing.sharedInstance.facebookUserId {
                self.profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
            } else {
                self.profileImageView.image = UIImage(named: "ProfileImage")
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawPolygonBezier(rect.midX,y: rect.midY,radius: rect.width/2, sides: 6, color: UIColor.defaultTurtleBackgroundColor())
        drawPolygonBezier2(rect.midX,y: rect.midY,radius: rect.width/2, sides: 6, color: UIColor.defaultYellowColor(), percent:CGFloat(progress))
        showCashLabel()
        drawCurrentSteps(rect.midX, y: rect.midY, radius: rect.width/2, sides: 6, percent: CGFloat(progress))
    }
    
    // MARK: - Helpers
    
    fileprivate func showCashLabel() {
        cashLabel.countFromCurrentValue(self.currentCash, duration: 4.0)
    }
    
    fileprivate func commonInit() {
        let textLabel = UILabel()
        textLabel.text = NSLocalizedString("TOTAL BALANCE", comment: "TOTAL BALANCE") //"TOTAL BALANCE"
        textLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
        textLabel.textColor = UIColor.defaultDarkGrayColor()
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
        
        let infoButton = UIButton(type: .custom)
        infoButton.contentMode = .scaleAspectFit
        infoButton.setImage(UIImage(named: "info"), for: UIControlState())
        infoButton.addTarget(self, action: #selector(TurtleView.infoPressed(_:)), for: .touchUpInside)
        self.addSubview(infoButton)
        
        cashLabel.textAlignment = .center
        self.addSubview(cashLabel)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        cashLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        let viewBindings = ["textLabel":textLabel, "cashLabel":cashLabel, "infoButton":infoButton]
        let infoButtonHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[textLabel]-(5.0)-[infoButton(22.0)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewBindings)
        self.addConstraints(infoButtonHorizontalConstraints)
        let cashLabelHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[cashLabel]|", options: [], metrics: nil, views: viewBindings)
        self.addConstraints(cashLabelHorizontalConstraints)
        let distance = 20.0 - (80.0 - 57.5)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-95.0-[textLabel(10.0)]-distance-[cashLabel(80.0)]", options: NSLayoutFormatOptions.alignAllCenterX, metrics: ["distance":distance], views: viewBindings)
        self.addConstraints(verticalConstraints)
        let infoButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[infoButton(22.0)]", options: [], metrics: nil, views: viewBindings)
        self.addConstraints(infoButtonVerticalConstraints)
        
        currentStepsIndicator.frame = CGRect(x: self.bounds.size.width / 2.0, y: 0.0, width: 15.0, height: 3.0)
        currentStepsIndicator.backgroundColor = UIColor.defaultYellowColor()
        
        currentStepsLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
        currentStepsLabel.frame = CGRect(x: self.bounds.size.width / 2.0, y: 0.0, width: 15.0, height: 3.0)
        currentStepsLabel.textColor = UIColor.defaultDarkGrayColor()
        self.addSubview(currentStepsLabel)
        
        currentStepsLabel.backgroundColor = UIColor.defaultYellowColor()
        currentStepsLabel.layer.cornerRadius = 2.0
        currentStepsLabel.clipsToBounds = true
        currentStepsLabel.text = "0"
        currentStepsLabel.sizeToFit()
        currentStepsLabel.center = CGPoint(x: self.bounds.size.width / 2.0, y: 0.0)
        currentStepsLabel.textAlignment = .center
        
        self.profileImageView.frame = CGRect(x: self.currentStepsLabel.frame.origin.x + self.currentStepsLabel.frame.width + 5.0, y: 0.0, width: 35.0, height: 35.0)
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2.0
        self.profileImageView.clipsToBounds = true
        self.addSubview(self.profileImageView)
        
        if let userId = FitVing.sharedInstance.facebookUserId {
            self.profileImageView.af_setImage(withURL: URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")!, placeholderImage: UIImage(named: "ProfileImage"), filter: nil, imageTransition: .crossDissolve(0.2))
        } else {
            self.profileImageView.image = UIImage(named: "ProfileImage")
        }

        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        cashLabel.setValueFormat("%.5f")
    }
    
    func degree2radian(_ a:CGFloat) -> CGFloat {
        let b = CGFloat(Double.pi) * a / 180
        return b
    }
    
    func polygonPointArray(_ sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat) -> [CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x
        let cy = y
        let r  = radius
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - (.pi / 2))
            let ypo = cy + r * sin(angle * CGFloat(i) - (.pi / 2))
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1;
        }
        return points
    }
    
    func polygonPath(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides, x: x, y: y, radius: radius)
        
        var cpg = points[0]
        path.move(to: cpg)
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
    func drawPolygonBezier(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor) {
        let path = polygonPath(x, y: y, radius: radius - 5.0, sides: sides)
        let bez = UIBezierPath(cgPath: path)
        UIColor.white.setFill()
        bez.fill()
        color.setStroke()
        bez.lineWidth = 10.0
        bez.stroke()
    }
    
    func drawPolygonBezier2(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor, percent: CGFloat) {
        for i in 0 ... 10 {
            let path = polygonPath(x, y: y, radius: radius - CGFloat(i), sides: sides)
            
            let points = polygonPointArray(sides, x: x, y: y, radius: radius - CGFloat(i))
            
            let point0 = points[0]
            let point1 = points[1]
            let point2 = points[2]
            let point3 = points[3]
            let point4 = points[4]
            let point5 = points[5]
            
            var distance: CGFloat = 0.0
            var deltaX = point1.x - point0.x
            var deltaY = point1.y - point0.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            deltaX = point2.x - point1.x
            deltaY = point2.y - point1.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            deltaX = point2.x - point3.x
            deltaY = point3.y - point2.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            deltaX = point3.x - point4.x
            deltaY = point3.y - point4.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            deltaX = point5.x - point4.x
            deltaY = point4.y - point5.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            deltaX = point0.x - point5.x
            deltaY = point5.y - point0.y
            distance += sqrt(deltaX * deltaX + deltaY * deltaY)
            
            let phase = CGFloat(0.0)
            let lengths = [distance * percent, distance * (1.0 - percent)].map { CGFloat($0) }
            let bez = UIBezierPath(cgPath: path)
            color.setStroke()
            bez.lineWidth = 1.0
            bez.setLineDash(lengths, count: lengths.count, phase: phase)
            bez.stroke()
        }
    }

    func drawCurrentSteps(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, percent: CGFloat) {
        let percentOfSide: CGFloat = 1.0 / 6.0
        let points = polygonPointArray(sides, x: x, y: y, radius: radius - 5.0)
        
        let point0 = points[0]
        let point1 = points[1]
        let point2 = points[2]
        let point3 = points[3]
        let point4 = points[4]
        let point5 = points[5]
        
        var distance: CGFloat = 0.0
        var deltaX = point1.x - point0.x
        var deltaY = point1.y - point0.y
        let distance0 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance0
        
        deltaX = point2.x - point1.x
        deltaY = point2.y - point1.y
        let distance1 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance1
        
        deltaX = point2.x - point3.x
        deltaY = point3.y - point2.y
        let distance2 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance2
        
        deltaX = point3.x - point4.x
        deltaY = point3.y - point4.y
        let distance3 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance3
        
        deltaX = point5.x - point4.x
        deltaY = point4.y - point5.y
        let distance4 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance4
        
        deltaX = point0.x - point5.x
        deltaY = point5.y - point0.y
        let distance5 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance5
        
        let anchorDistance = distance * percent
        var anchorPoint = CGPoint(x: self.bounds.size.width / 2.0, y: 0.0)
        
        guard !anchorDistance.isNaN else { return }
        
        if anchorDistance <= distance0 {
            anchorPoint = CGPoint(x: point0.x + (point1.x - point0.x) * percent / percentOfSide, y: point0.y + (point1.y - point0.y) * percent / percentOfSide)
        } else if anchorDistance <= (distance0 + distance1) {
            anchorPoint = CGPoint(x: point1.x, y: point1.y + (point2.y - point1.y) * (percent - percentOfSide) / percentOfSide)
        } else if anchorDistance <= (distance0 + distance1 + distance2) {
            anchorPoint = CGPoint(x: point2.x + (point3.x - point2.x) * (percent - percentOfSide * 2) / percentOfSide, y: point2.y + (point3.y - point2.y) * (percent - percentOfSide * 2) / percentOfSide)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3) {
            anchorPoint = CGPoint(x: point3.x + (point4.x - point3.x) * (percent - percentOfSide * 3) / percentOfSide, y: point3.y + (point4.y - point3.y) * (percent - percentOfSide * 3) / percentOfSide)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3 + distance4) {
            anchorPoint = CGPoint(x: point4.x, y: point4.y + (point5.y - point4.y) * (percent - percentOfSide * 4) / percentOfSide)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3 + distance4 + distance5) {
            anchorPoint = CGPoint(x: point5.x + (point0.x - point5.x) * (percent - percentOfSide * 5) / percentOfSide, y: point5.y + (point0.y - point5.y) * (percent - percentOfSide * 5) / percentOfSide)
        }
        print(anchorPoint)
        currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
        currentStepsLabel.sizeToFit()
        currentStepsLabel.frame.size.width += 10.0
        currentStepsLabel.frame.size.height += 10.0
        currentStepsLabel.center = anchorPoint
        
        if anchorDistance <= (distance0 + distance1 + distance2) {
            self.profileImageView.center = CGPoint(x: anchorPoint.x + self.currentStepsLabel.frame.width / 2.0 + 5.0 + 17.5, y: anchorPoint.y)
        } else {
            self.profileImageView.center = CGPoint(x: self.currentStepsLabel.frame.origin.x - 5.0 - 17.5, y: anchorPoint.y)
        }
    }

    func drawCurrentSteps_org(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, percent: CGFloat) {
        let percentOfSide: CGFloat = 1.0 / 6.0
        let points = polygonPointArray(sides, x: x, y: y, radius: radius)
        
        let point0 = points[0]
        let point1 = points[1]
        let point2 = points[2]
        let point3 = points[3]
        let point4 = points[4]
        let point5 = points[5]
        
        var distance: CGFloat = 0.0
        var deltaX = point1.x - point0.x
        var deltaY = point1.y - point0.y
        let distance0 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance0
        
        deltaX = point2.x - point1.x
        deltaY = point2.y - point1.y
        let distance1 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance1
        
        deltaX = point2.x - point3.x
        deltaY = point3.y - point2.y
        let distance2 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance2
        
        deltaX = point3.x - point4.x
        deltaY = point3.y - point4.y
        let distance3 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance3
        
        deltaX = point5.x - point4.x
        deltaY = point4.y - point5.y
        let distance4 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance4
        
        deltaX = point0.x - point5.x
        deltaY = point5.y - point0.y
        let distance5 = sqrt(deltaX * deltaX + deltaY * deltaY)
        distance += distance5
        
        let anchorDistance = distance * percent
        var anchorPoint = CGPoint(x: self.bounds.size.width / 2.0, y: 0.0)
        
        if anchorDistance <= distance0 {
            anchorPoint = CGPoint(x: point0.x + (point1.x - point0.x) * percent / percentOfSide, y: point0.y + (point1.y - point0.y) * percent / percentOfSide)
            
            anchorPoint.x += 5.0
            anchorPoint.y -= 3.0
            
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x, y: anchorPoint.y - currentStepsLabel.frame.size.height - 5.0)
            
        } else if anchorDistance <= (distance0 + distance1) {
            anchorPoint = CGPoint(x: point1.x, y: point1.y + (point2.y - point1.y) * (percent - percentOfSide) / percentOfSide)
            anchorPoint.x += 5.0
            
            
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x, y: anchorPoint.y - currentStepsLabel.frame.size.height - 5.0)
        } else if anchorDistance <= (distance0 + distance1 + distance2) {
            anchorPoint = CGPoint(x: point2.x + (point3.x - point2.x) * (percent - percentOfSide * 2) / percentOfSide, y: point2.y + (point3.y - point2.y) * (percent - percentOfSide * 2) / percentOfSide)
            anchorPoint.x += 5.0
            
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x, y: anchorPoint.y + 3.0 + 5.0)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3) {
            anchorPoint = CGPoint(x: point3.x + (point4.x - point3.x) * (percent - percentOfSide * 3) / percentOfSide, y: point3.y + (point4.y - point3.y) * (percent - percentOfSide * 3) / percentOfSide)
            anchorPoint.x -= (5.0 + 15.0)
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x - currentStepsLabel.frame.size.width + 15.0, y: anchorPoint.y + 3.0 + 5.0)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3 + distance4) {
            anchorPoint = CGPoint(x: point4.x, y: point4.y + (point5.y - point4.y) * (percent - percentOfSide * 4) / percentOfSide)
            anchorPoint.x -= (5.0 + 15.0)
            
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x - currentStepsLabel.frame.size.width + 15.0, y: anchorPoint.y - currentStepsLabel.frame.size.height - 5.0)
        } else if anchorDistance <= (distance0 + distance1 + distance2 + distance3 + distance4 + distance5) {
            anchorPoint = CGPoint(x: point5.x + (point0.x - point5.x) * (percent - percentOfSide * 5) / percentOfSide, y: point5.y + (point0.y - point5.y) * (percent - percentOfSide * 5) / percentOfSide)
            anchorPoint.x -= (5.0 + 15.0)
            anchorPoint.y -= 3.0
            
            currentStepsLabel.text = numberFormatter.string(from: NSNumber(value: currentSteps))
            currentStepsLabel.frame = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 100.0, height: 10.0)
            currentStepsLabel.sizeToFit()
            self.currentStepsLabel.frame.origin = CGPoint(x: anchorPoint.x - currentStepsLabel.frame.size.width + 15.0, y: anchorPoint.y - currentStepsLabel.frame.size.height - 5.0)
            
        }
        currentStepsIndicator.frame.origin = anchorPoint
    }

    // MARK: - Actions
    
    func infoPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "InfoPressed"), object: self)
    }
    
}
