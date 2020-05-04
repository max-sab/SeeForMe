//
//  ManagePageViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/4/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class ManagePageViewController: UIPageViewController {
    var currentIndex: Int?
    var buttonNames = ["Read text", "Identify color", "Saved texts", "Saved colors"]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self

        if let viewController = viewMainPageController(currentIndex ?? 0) {
            let viewControllers = [viewController]

            setViewControllers(viewControllers,
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }

    private func viewMainPageController(_ index: Int) -> MainPageViewController?{
        guard let storyboard = storyboard, let page = storyboard.instantiateViewController(withIdentifier: "MainPageViewController")
            as? MainPageViewController
            else {
                return nil
        }
        page.buttonName = buttonNames[index]
        page.buttonIndex = index
        return page
    }

    //code to support scrolling with accessibility and enable three finger swipe
    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {

        //down means literally down
        if direction == .down {
            guard let currentController = viewMainPageController(currentIndex ?? 0), let pageViewcontroller = pageViewController(self, viewControllerAfter: currentController) else {
                return false
            }

            //manually incrementing current index
            self.currentIndex = self.currentIndex == nil ? 0 : self.currentIndex! + 1
            //setting vcs manually, too
            self.setViewControllers([pageViewcontroller], direction: .forward, animated: true, completion: nil)
        } else if direction == .up {
            guard let currentController = viewMainPageController(currentIndex ?? 0), let pageViewcontroller = pageViewController(self, viewControllerBefore: currentController) else {
                return false
            }
            self.currentIndex = self.currentIndex == nil ? 0 : self.currentIndex! - 1
            self.setViewControllers([pageViewcontroller], direction: .reverse, animated: true, completion: nil)
        }

        UIAccessibility.post(notification: .pageScrolled,
                             argument: nil)

        return true
    }

}

extension ManagePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? MainPageViewController, let index = viewController.buttonIndex,
            index > 0 {
            return viewMainPageController(index - 1)
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? MainPageViewController, let index = viewController.buttonIndex,
            (index + 1) < buttonNames.count {
            return viewMainPageController(index + 1)
        }

        return nil
    }

    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }


}
