//
//  ViewController.swift
//  GLWalkthrough
//
//  Created by gokulgovind on 03/04/2021.
//  Copyright (c) 2021 gokulgovind. All rights reserved.
//

import UIKit
import GLWalkthrough

class ViewController: UITableViewController {

    var coachMarker:GLWalkThrough!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coachMarker = GLWalkThrough()
        coachMarker.dataSource = self
        coachMarker.delegate = self
        coachMarker.show()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showPreview(_ sender: UIBarButtonItem) {
        coachMarker = GLWalkThrough()
        coachMarker.dataSource = self
        coachMarker.delegate = self
        coachMarker.show()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}



// MARk: --
extension ViewController: GLWalkThroughDelegate {
    func didSelectNextAtIndex(index: Int) {
        if index == 7 {
            coachMarker.dismiss()
            let alert = UIAlertController(title: "Walkthrough Completed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didSelectSkip(index: Int) {
        coachMarker.dismiss()
    }
    
    
}
extension ViewController: GLWalkThroughDataSource {
    func getTabbarFrame(index:Int) -> CGRect? {
        if let bar = self.tabBarController?.tabBar.subviews {
            var idx = 0
            var frame:CGRect!
            for view in bar {
                if view.isKind(of: NSClassFromString("UITabBarButton")!) {
                    print(view.description)
                    if idx == index {
                        frame =  view.frame
                    }
                    idx += 1
                }
            }
            return frame
        }
        return nil
    }
    
    func numberOfItems() -> Int {
        return 7
    }
    
    func configForItemAtIndex(index: Int) -> GLWalkThroughConfig {
        let tabbarPadding:CGFloat = Helper.shared.hasTopNotch ? 88 : 50
        let overlaySize:CGFloat = Helper.shared.hasTopNotch ? 60 : 50
        let leftPadding:CGFloat = Helper.shared.hasTopNotch ? 10 : 5
        switch index {
        case 0:
            var config = GLWalkThroughConfig()
            config.title = "Home Screen"
            config.subtitle = "Here you can explore Services, Articles, plans"
            config.frameOverWindow = CGRect(x: 10, y: 37, width: overlaySize, height: overlaySize)
            config.position = .topLeft
            return config
        case 1:
            var config = GLWalkThroughConfig()
            config.title = "Restart"
            config.subtitle = "Restart walkthrough sample"
            config.frameOverWindow = CGRect(x: view.frame.size.width - 65, y: 45, width: overlaySize, height: overlaySize)
            config.position = .topRight
            return config
        case 2:
            guard let frame = getTabbarFrame(index: 0) else {
                return GLWalkThroughConfig()
            }
            var config = GLWalkThroughConfig()
            config.title = "Home Screen"
            config.subtitle = "Here you can explore Services, Articles, plans"
            config.frameOverWindow = CGRect(x: frame.origin.x + leftPadding, y: view.frame.size.height - tabbarPadding, width: overlaySize, height: overlaySize)
            
            return config
        case 3:
            guard let frame = getTabbarFrame(index: 1) else {
                return GLWalkThroughConfig()
            }
            var config = GLWalkThroughConfig()
            config.title = "Share"
            config.subtitle = "Consists Ongoing Expert chats, Plans, Requests"
            config.frameOverWindow = CGRect(x: frame.origin.x + leftPadding, y: view.frame.size.height - tabbarPadding, width: overlaySize, height: overlaySize)
            config.position = .bottomLeft
            return config
        case 4:
            guard let frame = getTabbarFrame(index: 2) else {
                return GLWalkThroughConfig()
            }
            var config = GLWalkThroughConfig()
            config.title = "General Queries"
            config.subtitle = "Ask your question in a General Forum"
            config.frameOverWindow = CGRect(x: frame.origin.x + leftPadding, y: view.frame.size.height - tabbarPadding, width: overlaySize, height: overlaySize)
            config.position = .bottomCenter
            return config
            
            
        case 5:
            guard let frame = getTabbarFrame(index: 3) else {
                return GLWalkThroughConfig()
            }
            var config = GLWalkThroughConfig()
            config.title = "My Profile"
            config.subtitle = "Your Account details, Wallets, Settings"
            config.frameOverWindow = CGRect(x: frame.origin.x + leftPadding, y: view.frame.size.height - tabbarPadding, width: overlaySize, height: overlaySize)
            config.position = .bottomRight
            return config
        case 6:
            guard let frame = getTabbarFrame(index: 4) else {
                return GLWalkThroughConfig()
            }
            var config = GLWalkThroughConfig()
            config.title = "ChatBot"
            config.subtitle = "Ask a Service, Query, Plan to Bot"
            config.nextBtnTitle = "Ask a Query"
            
            config.frameOverWindow = CGRect(x: frame.origin.x + leftPadding, y: view.frame.size.height - tabbarPadding, width: overlaySize, height: overlaySize)
            config.position = .bottomRight
            return config
        case 7:
            
            var config = GLWalkThroughConfig()
            config.title = "ChatBot"
            config.subtitle = "Ask a Service, Query, Plan to Bot"
            config.nextBtnTitle = "Ask a Query"
            
//            config.frameOverWindow = CGRect
            config.position = .bottomCenter
            return config
        default:
            return GLWalkThroughConfig()
        }
    }
    
    
}


struct Helper {
    static var shared = Helper()
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
