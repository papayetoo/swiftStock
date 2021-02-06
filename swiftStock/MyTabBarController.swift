//
//  MyTabBarController.swift
//  swiftStock
//
//  Created by 최광현 on 2021/02/05.
//

import UIKit

class MyTabBarController: UITabBarController {

    // 1 The circle will be our circle view for the selected tab
    private var circle: UIView?

    // 2. The image view will house the image within the circle, this combined
    // with the circle will create the following
    private var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // super view

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath(nil)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.shadowColor = UIColor(red: 123/255, green: 19/255, blue: 242/255, alpha: 0.95).cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0

        self.tabBar.backgroundColor = .clear
        self.tabBar.barTintColor = .white
        self.tabBar.layer.insertSublayer(shapeLayer, at: 1)
//        self.tabBar.layer.insertSublayer(circleLayer, at: 2)

        let mainNaviController = UINavigationController(rootViewController: StockMainViewController())
        mainNaviController.navigationBar.backgroundColor = .clear
        mainNaviController.navigationBar.barTintColor = .white
        mainNaviController.title = "Home"

        let homeTabItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        mainNaviController.tabBarItem = homeTabItem

        let addStarNavController = UINavigationController(rootViewController: AddStockViewController())
        addStarNavController.navigationBar.backgroundColor = .clear
        addStarNavController.navigationBar.barTintColor = .white

        let addStarTabItem = UITabBarItem(title: "addStar", image: UIImage(systemName: "star"), tag: 2)
        addStarNavController.tabBarItem = addStarTabItem
        addStarNavController.title = "Star"

        setCircle()

        self.viewControllers = [mainNaviController, addStarNavController]
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let idx = items.firstIndex(of: item) else {return}
        guard let selectedFrame = tabBar.items?[idx].value(forKey: "view") as? UIView else {return}

        let xPos = selectedFrame.frame.midX

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath(xPos)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.shadowColor = UIColor(red: 123/255, green: 19/255, blue: 242/255, alpha: 0.95).cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        guard let subLayers = tabBar.layer.sublayers else {return}

        circle?.center = CGPoint(x: selectedFrame.frame.midX, y: 0)

        let oldLayer = subLayers[1]
        tabBar.layer.replaceSublayer(oldLayer, with: shapeLayer)

        print("the selected index is : \(String(describing: items.firstIndex(of: item)))")
    }

    func createPath(_ xPos: CGFloat?) -> CGPath {

        let height: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = (xPos ?? self.view.layer.frame.width / 2)

        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))

        // complete the rect
        path.addLine(to: CGPoint(x: self.view.layer.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: self.view.layer.bounds.width, y: self.view.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: self.view.layer.bounds.height))
        path.close()

        return path.cgPath
    }

    func setCircle() {
        self.circle = UIView(frame: CGRect(x: self.view.frame.width/2, y: self.view.frame.origin.y + 10, width: 37.0, height: 37.0))
        self.circle?.layer.cornerRadius = 18.5
        self.circle?.center = CGPoint(x: self.view.center.x, y: 0.0)
        self.circle?.layer.backgroundColor = UIColor.white.cgColor
        self.circle?.layer.borderWidth = 0.5
        self.circle?.layer.borderColor = UIColor.systemPink.cgColor
        guard let circle = circle else {return}
        self.tabBar.addSubview(circle)
    }
}

extension MyTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("viewController ", viewController.tabBarItem.value(forKey: "view"))
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
