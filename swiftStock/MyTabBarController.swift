//
//  MyTabBarController.swift
//  swiftStock
//
//  Created by 최광현 on 2021/02/05.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.backgroundColor = .clear
        self.tabBar.barTintColor = .white
        let mainNaviController = UINavigationController(rootViewController: StockMainViewController())
        mainNaviController.navigationBar.backgroundColor = .clear
        mainNaviController.navigationBar.barTintColor = .white

        let homeTabItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        mainNaviController.tabBarItem = homeTabItem

        let addStarNavController = UINavigationController(rootViewController: AddStockViewController())
        addStarNavController.navigationBar.backgroundColor = .clear
        addStarNavController.navigationBar.barTintColor = .white

        let addStarTabItem = UITabBarItem(title: "addStar", image: UIImage(systemName: "star"), tag: 2)
        addStarNavController.tabBarItem = addStarTabItem

        self.viewControllers = [mainNaviController, addStarNavController]
    }

    // MARK: UITabBarDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let title = viewController.title else {return}
        print("selected \(String(describing: title))")
    }
}
