//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    var sentimentClassifier = TweetSentimentClassifier()
    var swifter: Swifter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwifter()
        if let swifter = swifter {
            swifter.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0...99 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                do {
                    var sentimentScore = 0
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    for pred in predictions {
                        let sentiment = pred.label
                        if sentiment == "Pos" {
                            sentimentScore += 1
                        } else if sentiment == "Neg" {
                            sentimentScore -= 1
                        }
                    }
                    print(sentimentScore)
                } catch {
                    print(error)
                }
                
            }) { (error) in
                print(error)
            }
        }
    }

    @IBAction func predictPressed(_ sender: Any) {
        
    }
    
    func setUpSwifter() {
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
