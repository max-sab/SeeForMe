//
//  ManagePageViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/4/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class ManagePageViewController: UIPageViewController {
    var currentIndex: Int!
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


}
