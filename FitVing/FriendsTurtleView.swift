
import UIKit

class FriendsTurtleView: UIView {

    var progress = 0.0
    var cashAmount = "$5.000"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        print("DRAW")
        drawPolygonBezier(rect.midX,y: rect.midY,radius: rect.width/2, sides: 6, color: UIColor.defaultLightGrayColor())
        drawPolygonBezier(rect.midX,y: rect.midY,radius: rect.width/2, sides: 6, color: UIColor.defaultYellowColor(), percent:CGFloat(progress))
    }
    
    // MARK: - Helpers
    
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.clear
    }
    
    func degree2radian(_ a:CGFloat)->CGFloat {
        let b = CGFloat(M_PI) * a/180
        return b
    }
    
    func polygonPointArray(_ sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat)->[CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x
        let cy = y
        let r  = radius
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - CGFloat(M_PI_2))
            let ypo = cy + r * sin(angle * CGFloat(i) - CGFloat(M_PI_2))
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
        let path = polygonPath(x, y: y, radius: radius - 2.5, sides: sides)
        let bez = UIBezierPath(cgPath: path)
        UIColor.white.setFill()
        bez.fill()
        color.setStroke()
        bez.lineWidth = 5.0
        bez.stroke()
    }
    
    func drawPolygonBezier(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor, percent: CGFloat) {
        for i in 0 ... 5 {
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
            let lengths = [distance * percent, distance * (1.0 - percent)
                ].map { CGFloat($0) }
            let bez = UIBezierPath(cgPath: path)
            color.setStroke()
            bez.lineWidth = 1.0
            bez.setLineDash(lengths, count: lengths.count, phase: phase)
            bez.stroke()
        }
    }
}
