//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    var swifter: Swifter?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getSwifter()
        swifter!.searchTweet(using: "@Apple", lang: "en", count: 100, success: { (results, metadata) in
            print(results)
        }) { (error) in
            print(error)
        }
    }

    @IBAction func predictPressed(_ sender: Any) {
        
    }
    
    func getSwifter() {
        var api = ""
        var api_secret = ""
        if let path = Bundle.main.path(forResource: "API", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, String> {
                api = dict["API_key"]!
                api_secret = dict["API_secret_key"]!
            }
        }
        swifter = Swifter(consumerKey: api, consumerSecret: api_secret)
    }
    
}
